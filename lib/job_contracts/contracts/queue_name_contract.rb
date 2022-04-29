# frozen_string_literal: true

require_relative "contract"

module JobContracts
  class QueueNameContract < Contract
    def initialize
      super trigger: :before, halt: true
    end

    def enforce!(contractable)
      self.satisfied = contractable.queue_name.to_s == expected[:queue_name].to_s
      super
    end
  end
end
