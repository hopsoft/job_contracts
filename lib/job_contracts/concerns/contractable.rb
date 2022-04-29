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
        should_perform = true
        contracts.select(&:before?).each do |contract|
          contract.enforce! self
          should_perform = false if contract.breached? && contract.halt?
        end
        super if should_perform
      ensure
        # enforce contracts in a separate thread to ensure that any perform related behavior
        # defined in ContractablePrepends will finish executing before we invoke contract.enforce!
        Thread.new do
          sleep 0
          synchronize do
            contracts.select(&:after?).each do |contract|
              contract.enforce! self
            end
          end
        end
      end
    end

    module ClassMethods
      attr_reader :after_contract_breach_callback

      def contracts
        @contracts ||= Set.new
      end

      def after_contract_breach(value = nil, &block)
        @after_contract_breach_callback = value || block
      end

      def add_contract(contract)
        if contract.class.const_defined?(:ContractableIncludes)
          include contract.class.const_get(:ContractableIncludes)
        end

        if contract.class.const_defined?(:ContractablePrepends)
          prepend contract.class.const_get(:ContractablePrepends)
        end

        prepend JobContracts::Contractable::Prepends

        contract.expected[:queue_name] = queue_name.to_sym
        contracts << contract
      end
    end

    delegate :contracts, to: "self.class"

    def breached_contracts
      @breached_contracts ||= Set.new
    end

    def after_contract_breach(contract)
      breached_contracts << contract
      method = self.class.after_contract_breach_callback
      case method
      when Proc then method.call(contract)
      when String, Symbol then send(method, contract)
      else raise NotImplementedError
      end
    end
  end
end
