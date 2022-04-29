# frozen_string_literal: true

require "observer"

module JobContracts
  class Contract
    include Observable

    attr_reader :trigger

    def initialize(trigger: :after, halt: false, **kwargs)
      @trigger = trigger.to_sym
      @halt = halt
      expected.merge! kwargs
    end

    def expected
      @expected ||= HashWithIndifferentAccess.new
    end

    def actual
      @actual ||= HashWithIndifferentAccess.new
    end

    # Method to be implemented by subclasses
    # NOTE: subclasses should update `actual`, set `satisfied`, and call `super`
    def enforce!(contractable)
      actual[:queue_name] = contractable.queue_name
      add_observer contractable, :after_contract_breach
      changed if breached?
      notify_observers self
    ensure
      delete_observer contractable
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

    protected

    attr_accessor :satisfied
  end
end
