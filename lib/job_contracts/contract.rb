module JobContracts
  module Contract
    extend ActiveSupport::Concern

    included do
      amend_contract job: name, expected: {}, actual: {}
      define_callbacks :contract_breached, scope: [:kind, :name]
    end

    module ClassMethods
      attr_reader :contract

      def expect(options = {})
        amend_contract expected: options
      end

      def amend_contract(options = {})
        @contract ||= {}.with_indifferent_access
        @contract.merge! options
      end

      def after_contract_breached(*filters, &block)
        set_callback(:contract_breached, :after, *filters, &block)
      end
    end

    delegate :contract, to: "self.class"

    protected

    def contract_breached?
      !!@contract_breached
    end

    def breach_contract!
      @contract_breached = true
      run_callbacks :contract_breached
    end
  end
end
