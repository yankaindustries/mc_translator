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
      args = {
        userId: config['userId'],
        userSecret: config['userSecret'],
        projectId: config['projectId'],
      }

      @files = Smartling::File.new(args)
      @jobs = Smartling::Job.new(args)
    end

    def push_changed
      push changed_files
    end

    def push_all
      push all_files
    end

    def pull_job
      pull job_files
    end

    def pull_all
      pull all_files
    end

    private

    def config
      YAML.safe_load(File.read('.translator.yml'))
    end

    def git
      Git.open(Dir.getwd)
    end

    def origin
      current_branch = git.current_branch
      parent_branch = config['parentBranch']

      if current_branch == config['parentBranch']
        first_commit = git.log.last
      else
        first_commit = git.log.between(parent_branch, current_branch).last
      end

      first_commit.parent
    end

    def changed_files
      config['matches'].flat_map do |matcher|
        git.diff(origin.sha)
          .select { |file| File.fnmatch(matcher['pattern'], file.path) }
          .select { |file| %w(new modified).include? file.type }
          .map { |file| { path: file.path, name: file.path, type: matcher['type'] } }
      end
    end

    def all_files
      config['matches'].flat_map do |matcher|
        Dir.glob(matcher['pattern']).map do |file|
          p matcher['pattern'], file
          { path: file, name: file, type: matcher['type'] }
        end
      end
    end

    def job_files
      current_branch = git.current_branch

      print_msg 'Getting job and files...'
      job = @jobs.list['items'].detect { |j| j['jobName'] == current_branch }
      @jobs.files(job['translationJobUid'])['items'].map do |file|
        { path: file['uri'], name: file['uri'] }
      end
    end

    def push(files)
      current_branch = git.current_branch

      print_msg 'Setting up job...'
      job = @jobs.find_or_create current_branch
      p job['translationJobUid']

      print_msg 'Uploading files...'
      files.each do |file|
        p file[:path]
        begin
          @files.upload file[:path], file[:path], file[:type]
          @jobs.add_file job['translationJobUid'], file[:path], config['locales']
        rescue => error
          p error
        end
      end

      # There's some sort of lag between the creating a job and the API
      # returning the correct status, so we add a little delay to compensate
      sleep 2

      print_msg 'Checking job...'
      job = @jobs.detail job['translationJobUid']
      p job['jobStatus']

      if job['jobStatus'] == 'AWAITING_AUTHORIZATION'
        print_msg 'Authorizing job...'
        @jobs.authorize job["translationJobUid"]
      end

      job
    end

    def pull(files)
      files
        .map do |file| file[:path] end
        .each do |file|
          config['locales'].each do |locale|
            expansion = {
              locale: locale,
              dir: File.dirname(file),
              name: File.basename(file, '.*').gsub(/en-US/, ''),
              ext: File.extname(file),
            }

            name = File.expand_path(config['rewrite'] % expansion)
            content = @files.download_translated(
                        file,
                        locale,
                        { retrievalType: 'published' }
                      )

            p file
            p name

            dir = File.dirname(name)
            Dir.mkdir(dir) unless Dir.exist?(dir)
            File.write(name, content)
          end
        end
    end
  end
end
