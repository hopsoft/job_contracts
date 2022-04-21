require_relative "../contract"

module JobContracts
  module ActiveJob
    class QueueNameContract < Contract
      def initialize(queue_name:)
        super trigger: :before, halt: true, queue_name: queue_name
      end

      def enforce!(contractable)
        actual[:queue_name] = contractable.queue_name
        self.satisfied = contractable.queue_name.to_s == expect[:queue_name].to_s
        super
      end
    end
  end
end
