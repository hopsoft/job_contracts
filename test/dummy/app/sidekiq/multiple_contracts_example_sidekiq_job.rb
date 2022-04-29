# frozen_string_literal: true

class MultipleContractsExampleSidekiqJob
  include Sidekiq::Job
  include JobContracts::SidekiqContractable

  sidekiq_options queue: :low

  add_contract JobContracts::QueueNameContract.new
  add_contract JobContracts::DurationContract.new(duration: 1.second)
  add_contract JobContracts::ReadOnlyContract.new
  after_contract_breach :contract_breached

  def perform
    sleep 2
    User.create! name: "test"
  end

  private

  def contract_breached(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.inspect}"

    if contract.is_a?(JobContracts::QueueNameContract)
      # re-enqueue to the queue expected by the queue name contract
      self.class.set(queue: contract.expected[:queue_name]).perform_async
    end
  end
end
