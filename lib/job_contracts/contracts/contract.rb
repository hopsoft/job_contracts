# frozen_string_literal: true

module JobContracts
  class Contract
    attr_reader :trigger, :queues

    def initialize(trigger: :after, halt: false, queues: [], expected: {})
      @trigger = trigger.to_sym
      @halt = halt
      @queues = Set.new(queues.map(&:to_s))
      self.expected.merge! expected
    end

    def expected
      @expected ||= HashWithIndifferentAccess.new
    end

    def actual
      @actual ||= HashWithIndifferentAccess.new
    end

    def should_enforce?(contractable)
      return true if queues.include?("*")
      queues.include? contractable.queue_name.to_s
    end

    # Method to be implemented by subclasses
    # NOTE: subclasses should update `actual`, set `satisfied`, and call `super`
    def enforce!(contractable)
      return unless should_enforce?(contractable)
      return if satisfied?
      contractable.breached_contracts << self
      invoke_contract_breach_callback contractable
    end

    def satisfied?
      !!satisfied
    end

    def breached?
      !satisfied?
    end

    def halt?
      !!@halt
    end

    def before?
      trigger == :before
    end

    def after?
      trigger == :after
    end

    def to_h
      HashWithIndifferentAccess.new(
        name: self.class.name,
        trigger: trigger,
        halt: halt?,
        queues: queues.to_a,
        expected: expected,
        actual: actual
      )
    end

    protected

    attr_accessor :satisfied

    def invoke_contract_breach_callback(contractable)
      callback = contractable.class.on_contract_breach_callback
      callback = contractable.method(callback.to_sym) unless callback.is_a?(Proc)
      callback.call self
    end
  end
end
