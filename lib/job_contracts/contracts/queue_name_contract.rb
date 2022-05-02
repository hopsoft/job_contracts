# frozen_string_literal: true

require_relative "contract"

module JobContracts
  class QueueNameContract < Contract
    def initialize(queue_name:)
      super(
        trigger: :before,
        halt: true,
        queues: ["*"],
        expected: {queue_name: queue_name.to_s}
      )
    end

    def enforce!(contractable)
      actual[:queue_name] = contractable.queue_name.to_s
      self.satisfied = contractable.queue_name.to_s == expected[:queue_name]
      super
    end
  end
end
