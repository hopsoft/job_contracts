module JobContracts
  # Universal mixin for jobs/workers
  module Contractable
    extend ActiveSupport::Concern

    module Prepends
      extend ActiveSupport::Concern

      def perform(*args)
        should_perform = true
        self.class.contracts_to_enforce_before_perform.each do |contract|
          contract.enforce! self
          should_perform = false if contract.breached? && contract.halt?
        end
        super if should_perform
        self.class.contracts_to_enforce_after_perform.each do |contract|
          contract.enforce! self
        end
      end
    end

    module ClassMethods
      attr_reader :after_contract_breach_callback

      def contracts_to_enforce_before_perform
        @contracts_to_enforce_before_perform ||= Set.new
      end

      def contracts_to_enforce_after_perform
        @contracts_to_enforce_after_perform ||= Set.new
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

        if contract.trigger == :before
          contracts_to_enforce_before_perform << contract
        else
          contracts_to_enforce_after_perform << contract
        end
      end
    end

    def after_contract_breach(contract)
      method = self.class.after_contract_breach_callback
      case method
      when Proc then method.call(contract)
      when String, Symbol then send(method, contract)
      else raise NotImplementedError
      end
    end
  end
end
