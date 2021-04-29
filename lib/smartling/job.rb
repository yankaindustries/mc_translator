require 'smartling'

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
        create(name)
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
