# frozen_string_literal: true

class DurationExampleSidekiqJob
  include Sidekiq::Job
  include JobContracts::SidekiqContractable

  sidekiq_options queue: :default
  add_contract JobContracts::DurationContract.new(max: 1.second)

  def perform
    sleep 2
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.to_h.inspect}"
  end
end
