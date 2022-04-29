# frozen_string_literal: true

class ReadOnlyExampleSidekiqJob
  include Sidekiq::Job
  include JobContracts::SidekiqContractable

  sidekiq_options queue: :low

  add_contract JobContracts::ReadOnlyContract.new
  after_contract_breach :contract_breached

  def perform
    User.create! name: "test"
  end

  private

  def contract_breached(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.inspect}"
  end
end
