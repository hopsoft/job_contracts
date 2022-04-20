require_relative "contract"

module JobContracts
  module DurationContract
    extend ActiveSupport::Concern
    include Contract

    included do
      amend_contract contract: name
      after_perform :enforce_contract!
    end

    private

    def enforce_contract!
      duration = (Time.current - Time.parse(enqueued_at)).seconds
      contract[:actual][:duration] = duration
      breach_contract! if duration > contract[:expected][:duration].in_seconds
    end
  end
end
