# frozen_string_literal: true

class MultipleContractsExampleJob < ApplicationJob
  include JobContracts::Contractable

  queue_as :low
  add_contract JobContracts::QueueNameContract.new(queue_name: :low)
  add_contract JobContracts::DurationContract.new(duration: 1.second)
  add_contract JobContracts::ReadOnlyContract.new

  def perform
    sleep 2
    User.create! name: "test"
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.inspect}"

    # re-enqueue to the queue expected by the queue name contract
    enqueue queue: contract.expected[:queue_name] if contract.is_a?(JobContracts::QueueNameContract)
  end
end
