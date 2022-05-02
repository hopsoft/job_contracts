# frozen_string_literal: true

class MultipleContractsExampleSidekiqJob
  include Sidekiq::Job
  include JobContracts::SidekiqContractable

  sidekiq_options queue: :low

  add_contract JobContracts::QueueNameContract.new(queue_name: :low)
  add_contract JobContracts::DurationContract.new(max: 1.second)
  add_contract JobContracts::ReadOnlyContract.new

  def perform
    sleep 2
    User.create! name: "test"
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.inspect}"

    if contract.is_a?(JobContracts::QueueNameContract)
      # re-enqueue to the queue expected by the queue name contract
      self.class.set(queue: contract.expected[:queue_name]).perform_async
    end
  end
end
