# frozen_string_literal: true

require "monitor"

module JobContracts
  # Universal mixin for jobs/workers
  module Contractable
    extend ActiveSupport::Concern

    module Prepends
      extend ActiveSupport::Concern
      include MonitorMixin

      def perform(*args)
        # fetch sidekiq job/worker metadata on main thread
        try :sidekiq_job_metadata

        halted = false
        contracts.select(&:before?).each do |contract|
          contract.enforce! self unless halted
          halted = true if contract.breached? && contract.halt?
        end
        super unless halted
      ensure
        # enforce after contracts in a separate thread to ensure that any perform related behavior
        # defined in ContractablePrepends will finish executing before we invoke contract.enforce!
        Thread.new do
          sleep 0
          synchronize do
            contracts.select(&:after?).each do |contract|
              contract.enforce! self unless halted
            end
          end
        end
      end
    end

    module ClassMethods
      def contracts
        @contracts ||= Set.new
      end

      def on_contract_breach(value = nil, &block)
        @on_contract_breach_callback = value || block
      end

      def on_contract_breach_callback
        @on_contract_breach_callback ||= :contract_breached!
      end

      def add_contract(contract)
        if contract.class.const_defined?(:ContractableIncludes)
          include contract.class.const_get(:ContractableIncludes)
        end

        if contract.class.const_defined?(:ContractablePrepends)
          prepend contract.class.const_get(:ContractablePrepends)
        end

        prepend JobContracts::Contractable::Prepends

        contract.queues << queue_name.to_s if contract.queues.blank? && queue_name.present?
        contract.queues << "*" if contract.queues.blank?
        contracts << contract
      end
    end

    delegate :contracts, to: "self.class"

    def breached_contracts
      @breached_contracts ||= Set.new
    end

    # Default callback
    def contract_breached!
      # noop / override in job subclasses
    end
  end
end
