require_relative "../contract"

module JobContracts
  module ActiveJob
    class ReadOnlyContract < Contract
      module ContractablePrepends
        extend ActiveSupport::Concern

        def perform(*args)
          ActiveRecord::Base.while_preventing_writes do
            super
          end
        end
      end

      module ContractableIncludes
        extend ActiveSupport::Concern

        included do
          attr_reader :read_only_error

          rescue_from(ActiveRecord::ReadOnlyError) do |error|
            @read_only_error = error
          end
        end
      end

      def initialize
        super trigger: :before
      end

      def enforce!(contractable)
        if contractable.read_only_error.present?
          actual[:error] = contractable.read_only_error.message
          self.satisfied = false
        end
        super
      end
    end
  end
end
