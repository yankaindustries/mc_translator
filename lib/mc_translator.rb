# frozen_string_literal: true

require_relative 'mc_translator/version'
require 'smartling'
require 'yaml'
require 'git'

module Smartling
  class Job < Api
    def initialize(args = {})
      super(args)
      @project_id = args[:projectId]
    end

    def list
      uri = uri("jobs-api/v3/projects/#{@project_id}/jobs")
      return get(uri)
    end

    def detail(job_id)
      uri = uri("/jobs-api/v3/projects/#{@project_id}/jobs/#{job_id}")
      return get(uri)
    end

    def create(name)
      keys = { jobName: name }
      uri = uri("jobs-api/v3/projects/#{@project_id}/jobs", keys)
      return post(uri, uri.params)
    end

    def find_or_create(name)
      list['items'].find do |job| job['jobName'] == name end ||
        @jobs.create(name)
    end

    def files(job_id)
      uri = uri("jobs-api/v3/projects/#{@project_id}/jobs/#{job_id}/files")
      return get(uri)
    end

    def add_file(job_id, file_uri, locales)
      keys = { fileUri: file_uri, targetLocaleIds: locales }
      uri = uri("jobs-api/v3/projects/#{@project_id}/jobs/#{job_id}/file/add", keys)
      return post(uri, uri.params)
    end

    def authorize(job_id)
      uri = uri("jobs-api/v3/projects/#{@project_id}/jobs/#{job_id}/authorize")
      return post(uri, uri.params)
    end

  end
end


module McTranslator
  class Error < StandardError; end

  class Translator
    def print_msg(msg)
      puts
      puts msg
    end

    def initialize
      @config = YAML.safe_load(File.read('translator.yml'))
      args = {
        userId: @config['userId'],
        userSecret: @config['userSecret'],
        projectId: @config['projectId'],
      }

      @files = Smartling::File.new(args)
      @jobs = Smartling::Job.new(args)
      @g = Git.open(Dir.getwd)
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
  end
end
