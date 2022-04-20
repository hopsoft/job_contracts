require_relative "contract"

module JobContracts
  module QueueNameContract
    extend ActiveSupport::Concern
    include Contract

    module Performer
      def perform(*args)
        return if contract_breached?
        super
      end
    end

    included do
      prepend JobContracts::QueueNameContract::Performer
      before_perform :enforce_contract!
    end

    private

    def enforce_contract!
      contract[:actual][:queue_name] = queue_name
      breach_contract! if queue_name.to_s != contract[:expected][:queue_name].to_s
    end
  end
end
