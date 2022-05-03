# frozen_string_literal: true

require_relative "contract"

module JobContracts
  class DurationContract < Contract
    def initialize(max:, queues: ["*"])
      super queues: queues, expected: {max: max}
    end

    def enforce!(contractable)
      actual[:duration] = (Time.current - Time.parse(contractable.enqueued_at)).seconds
      self.satisfied = actual[:duration] < expected[:max].seconds
      super
    end
  end
end
