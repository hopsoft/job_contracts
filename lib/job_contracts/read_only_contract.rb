require_relative "contract"

module JobContracts
  module ReadOnlyContract
    extend ActiveSupport::Concern
    include Contract

    module Performer
      def perform(*args)
        ActiveRecord::Base.while_preventing_writes do
          super
        end
      end
    end

    included do
      prepend JobContracts::ReadOnlyContract::Performer
      rescue_from(ActiveRecord::ReadOnlyError) { |error| enforce_contract! error }
    end

    private

    def enforce_contract!(error)
      contract[:actual][:error] = error.message
      breach_contract!
    end
  end
end
