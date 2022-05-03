# frozen_string_literal: true

class ArgumentExampleSidekiqJob
  include Sidekiq::Job
  include JobContracts::SidekiqContractable

  sidekiq_options queue: :default
  add_contract ArgumentContract.new(range: (1..10))

  def perform(arg)
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.to_h.inspect}"
  end
end
