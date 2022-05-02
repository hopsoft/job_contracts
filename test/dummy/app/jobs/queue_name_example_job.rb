# frozen_string_literal: true

class QueueNameExampleJob < ApplicationJob
  include JobContracts::Contractable

  queue_as :low

  add_contract JobContracts::QueueNameContract.new

  def perform(*args)
    Rails.logger.info "Actually performed on: #{queue_name}"
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.inspect}"

    # re-enqueue to the queue expected by the contract
    enqueue queue: contract.expected[:queue_name]
  end
end
