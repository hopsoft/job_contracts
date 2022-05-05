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

        halted = enforce_contracts!(contracts.select(&:before?))
        super unless halted
      ensure
        unless halted
          # enforce after-contracts in a separate thread to ensure that any perform related behavior
          # defined in ContractablePrepends will finish executing before we invoke contract.enforce!
          # important when multiple contracts have been applied
          Thread.new do
            sleep 0
            synchronize { enforce_contracts! contracts.select(&:after?) }
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

    private

    def enforce_contracts!(contracts)
      halted = false
      contracts.each do |contract|
        next if halted
        contract.enforce! self
        halted ||= contract.breached? && contract.halt?
      end
      halted
    end
  end
end
