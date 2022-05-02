# frozen_string_literal: true

require "observer"

module JobContracts
  class Contract
    include Observable

    attr_reader :trigger

    def initialize(trigger: :after, halt: false, enforce_on_all_queues: false, **kwargs)
      @trigger = trigger.to_sym
      @halt = halt
      @enforce_on_all_queues = enforce_on_all_queues
      expected.merge! kwargs
    end

    def expected
      @expected ||= HashWithIndifferentAccess.new
    end

    def actual
      @actual ||= HashWithIndifferentAccess.new
    end

    def should_enforce?
      return true if enforce_on_all_queues?
      actual[:queue_name] == expected[:queue_name]
    end

    # Method to be implemented by subclasses
    # NOTE: subclasses should update `actual`, set `satisfied`, and call `super`
    def enforce!(contractable)
      actual[:queue_name] = contractable.queue_name.to_s
      return unless should_enforce?
      add_observer contractable, :on_contract_breach
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

    def enforce_on_all_queues?
      !!@enforce_on_all_queues
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
