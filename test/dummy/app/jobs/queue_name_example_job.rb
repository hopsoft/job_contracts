# frozen_string_literal: true

class QueueNameExampleJob < ApplicationJob
  include JobContracts::Contractable

  queue_as :low

  add_contract JobContracts::QueueNameContract.new(queue_name: :low)
  after_contract_breach :contract_breached

  def perform(*args)
    Rails.logger.info "Actually performed on: #{queue_name}"
  end

  private

  def contract_breached(contract)
    # TODO: notify error monitoring service
    Rails.logger.info "Contract breached! #{contract.inspect}"

    # re-enqueue to the queue expected by the contract
    enqueue queue: contract.expected[:queue_name]
  end
end
