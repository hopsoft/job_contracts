require_relative "../contract"

module JobContracts
  module Sidekiq
    class DurationContract < Contract
      def initialize(duration:)
        super
      end

      def enforce!(contractable)
        work_set = ::Sidekiq::WorkSet.new
        metadata = work_set.find do |_pid, _tid, data|
          data.dig("payload", "jid") == contractable.jid
        end
        seconds = metadata.last.dig("payload", "enqueued_at")
        enqueued_at = Time.at(seconds)

        actual[:duration] = (Time.current - enqueued_at).seconds
        self.satisfied = actual[:duration] < expect[:duration].seconds
        super
      end
    end
  end
end
