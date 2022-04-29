# frozen_string_literal: true

require_relative "contract"

module JobContracts
  class ReadOnlyContract < Contract
    module ContractablePrepends
      extend ActiveSupport::Concern

      def perform(*args)
        contract = contracts.find { |c| c.is_a?(ReadOnlyContract) }
        if contract.expected[:queue_name].to_s == queue_name.to_s
          ActiveRecord::Base.while_preventing_writes do
            super
          end
        else
          super
        end
      rescue ActiveRecord::ReadOnlyError => error
        @read_only_error = error
      end
    end

    module ContractableIncludes
      extend ActiveSupport::Concern
      included do
        attr_reader :read_only_error
      end
    end

    def enforce!(contractable)
      self.satisfied = true
      if contractable.read_only_error.present?
        actual[:error] = contractable.read_only_error.message
        self.satisfied = false
      end
      super
    end
  end
end
