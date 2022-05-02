# frozen_string_literal: true

require_relative "contract"

module JobContracts
  class QueueNameContract < Contract
    def initialize
      super trigger: :before, halt: true, enforce_on_all_queues: true
    end

    def enforce!(contractable)
      self.satisfied = contractable.queue_name.to_s == expected[:queue_name]
      super
    end
  end
end
