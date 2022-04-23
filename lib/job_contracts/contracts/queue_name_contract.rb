# frozen_string_literal: true

require_relative "contract"

module JobContracts
  class QueueNameContract < Contract
    def initialize(queue_name:)
      super trigger: :before, halt: true, queue_name: queue_name
    end

    def enforce!(contractable)
      queue_name = contractable.queue_name
      actual[:queue_name] = queue_name
      self.satisfied = queue_name.to_s == expect[:queue_name].to_s
      super
    end
  end
end
