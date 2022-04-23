# frozen_string_literal: true

class QueueNameExampleSidekiqJob
  include Sidekiq::Job
  include JobContracts::SidekiqContractable

  sidekiq_options queue: :low

  add_contract JobContracts::QueueNameContract.new(queue_name: :low)
  after_contract_breach :contract_breached

  def perform
    Rails.logger.info "Actually performed on: #{queue_name}"
  end

  private

  def contract_breached(contract)
    # TODO: notify error monitoring service
    Rails.logger.info "Contract violation! #{contract.inspect}"

    # re-enqueue to the queue expected by the contract
    self.class.set(queue: contract.expect[:queue_name]).perform_async
  end
end
