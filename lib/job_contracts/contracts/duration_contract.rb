# frozen_string_literal: true

require_relative "contract"

module JobContracts
  class DurationContract < Contract
    def initialize(duration:, queues: ["*"], **kwargs)
      super duration: duration, queues: queues, **kwargs
    end

    def enforce!(contractable)
      actual[:duration] = (Time.current - Time.parse(contractable.enqueued_at)).seconds
      self.satisfied = actual[:duration] < expected[:duration].seconds
      super
    end
  end
end
