# frozen_string_literal: true

require_relative "contractable"

module JobContracts
  # Sidekiq mixin for jobs/workers
  module SidekiqContractable
    extend ActiveSupport::Concern
    include Contractable

    class SidekiqJobMetadataNotFoundError < StandardError; end

    module ClassMethods
      def queue_name
        sidekiq_options_hash["queue"]
      end
    end

    def sidekiq_job_metadata
      @sidekiq_job_metadata ||= begin
        hit = nil
        begin
          attempts ||= 1
          hit = Sidekiq::Workers.new.find do |_process_id, _thread_id, work|
            work.dig("payload", "jid") == jid
          end
          raise SidekiqJobMetadataNotFoundError if hit.blank?
        rescue SidekiqJobMetadataNotFoundError
          # The WorkSet only updates every 5 seconds
          # SEE: https://github.com/mperham/sidekiq/wiki/API#workers
          # Re-attempt up to 10 times with a simple backoff strategy (up to 5.5 seconds)
          # TODO: Is there a faster and more reliable way to fetch the job's metadata after perform has begun?
          #       May need to query Redis directly if the data is still in there at this point
          attempts += 1
          if attempts <= 10
            sleep 0.1 * attempts
            retry
          end
        end

        hit&.last || {}
      end
    end

    # Matches the ActiveJob API
    def queue_name
      sidekiq_job_metadata["queue"]
    end

    # Matches the ActiveJob API
    def enqueued_at
      seconds = sidekiq_job_metadata.dig("payload", "enqueued_at")
      (seconds ? Time.at(seconds) : nil)&.iso8601.to_s
    end

    # Matches the ActiveJob API
    def arguments
      sidekiq_job_metadata.dig("payload", "args") || []
    end
  end
end
