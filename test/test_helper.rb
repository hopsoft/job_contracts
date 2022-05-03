# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "pry"
require "pry-doc"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"
require "minitest/mock"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

require_relative "jobs/concerns/test_contractable_active_job"
DurationExampleJob.send :include, TestContractableActiveJob
MultipleContractsExampleJob.send :include, TestContractableActiveJob
QueueNameExampleJob.send :include, TestContractableActiveJob
ReadOnlyExampleJob.send :include, TestContractableActiveJob
ArgumentExampleJob.send :include, TestContractableActiveJob

# stub enqueue for ActiveJob classes that reenqueue
[MultipleContractsExampleJob, QueueNameExampleJob].each do |job_class|
  job_class.class_eval do
    def enqueues
      @enqueues ||= []
    end

    define_method :enqueue do |options = {}|
      if breached_contracts.blank?
        super queue: options[:queue]
      else
        enqueues << options
      end
    end
  end
end
