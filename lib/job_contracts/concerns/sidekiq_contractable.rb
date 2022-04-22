require_relative "contractable"

module JobContracts
  # Sidekiq mixin for jobs/workers
  module SidekiqContractable
    extend ActiveSupport::Concern
    include Contractable

    class MetadataNotFoundError < StandardError; end

    def metadata
      hit = nil
      begin
        attempts ||= 1
        hit = Sidekiq::WorkSet.new.find do |_pid, _tid, work|
          work.dig("payload", "jid") == jid
        end
        raise MetadataNotFoundError if hit.blank?
      rescue MetadataNotFoundError
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

    # Matches the ActiveJob API
    def queue_name
      metadata["queue"]
    end

    # Matches the ActiveJob API
    def enqueued_at
      seconds = metadata.dig("payload", "enqueued_at")
      (seconds ? Time.at(seconds) : nil)&.iso8601.to_s
    end
  end
end
