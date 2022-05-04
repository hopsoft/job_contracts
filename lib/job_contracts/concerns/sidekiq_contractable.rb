# frozen_string_literal: true

require_relative "contractable"

module JobContracts
  # Sidekiq mixin for jobs/workers
  module SidekiqContractable
    extend ActiveSupport::Concern
    include Contractable

    module ClassMethods
      # Matches the ActiveJob API
      def queue_name
        sidekiq_options_hash["queue"]
      end
    end

    # Metadata used to enqueue the job
    def sidekiq_job_hash
      @sidekiq_job_hash ||= {}
    end

    # Matches the ActiveJob API
    def queue_name
      sidekiq_job_hash["queue"]
    end

    # Matches the ActiveJob API
    def enqueued_at
      seconds = sidekiq_job_hash["enqueued_at"]
      (seconds ? Time.at(seconds) : nil)&.iso8601.to_s
    end

    # Matches the ActiveJob API
    def arguments
      sidekiq_job_hash["args"] || []
    end
  end
end
