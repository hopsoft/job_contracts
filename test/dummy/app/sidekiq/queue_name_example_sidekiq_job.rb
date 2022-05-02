# frozen_string_literal: true

class QueueNameExampleSidekiqJob
  include Sidekiq::Job
  include JobContracts::SidekiqContractable

  sidekiq_options queue: :low

  add_contract JobContracts::QueueNameContract.new

  def perform
    Rails.logger.info "Actually performed on: #{queue_name}"
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.inspect}"

    # re-enqueue to the queue expected by the contract
    self.class.set(queue: contract.expected[:queue_name]).perform_async
  end
end
