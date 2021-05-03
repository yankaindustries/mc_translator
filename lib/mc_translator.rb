# frozen_string_literal: true

require_relative 'mc_translator/version'
require_relative 'mc_translator/tasks'
require_relative 'smartling/job'
require 'yaml'
require 'git'
require 'smartling'


module McTranslator
  class Error < StandardError; end

  class Translator
    def print_msg(msg)
      puts
      puts msg
    end

    def initialize
      @config = YAML.safe_load(File.read('.translator.yml'))
      p @config
      args = {
        userId: @config['userId'],
        userSecret: @config['userSecret'],
        projectId: @config['projectId'],
      }

      @g = Git.open(Dir.getwd)

      @files = Smartling::File.new(args)
      @jobs = Smartling::Job.new(args)
    end

    def push
      current_branch = @g.current_branch
      parent_branch = @config['parentBranch']
      if current_branch == @config['parentBranch']
        first_commit = @g.log.last
      else
        first_commit = @g.log.between(parent_branch, current_branch).last
      end
      origin_commit = first_commit.parent
      files = @config['matches'].flat_map { |match|

        @g.diff(origin_commit.sha)
          .select { |file| File.fnmatch(match['pattern'], file.path) }
          .select { |file| %w(new modified).include? file.type }
          .map { |file| { path: file.path, name: file.path, type: match['type'] } }
      }

      print_msg 'Finding or Creating job...'
      job = @jobs.find_or_create current_branch
      p job

      print_msg 'Uploading files...'
      files.each { |file|
        p file
        p @files.upload file[:path], file[:path], file[:type]
        p @jobs.add_file job['translationJobUid'], file[:path], @config['locales']
      }

      # There's some sort of lag between the creating a job and the API
      # returning the correct status, so we add a little delay to compensate
      sleep 2

      print_msg 'Checking job...'
      job = @jobs.detail job['translationJobUid']
      p job

      if job['jobStatus'] == 'AWAITING_AUTHORIZATION'
        print_msg 'Authorizing job...'
        p @jobs.authorize job["translationJobUid"]
      end
    end

    def pull
      current_branch = @g.current_branch

      job = @jobs.list['items'].detect { |j| j['jobName'] == current_branch }
      files = @jobs.files(job['translationJobUid'])['items']
      files
        .map { |file| file['uri'] }
        .each { |file|
          @config['locales'].each { |locale|
            name = file.sub 'en-US', locale
            content = @files.download_translated file, locale

            File.write(name, content)
          }
        }
    end

    private

    def get_files

    end
  end
end
