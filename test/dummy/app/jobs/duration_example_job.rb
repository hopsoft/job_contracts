# frozen_string_literal: true

class DurationExampleJob < ApplicationJob
  include JobContracts::Contractable

  queue_as :default

  add_contract JobContracts::DurationContract.new(duration: 1.second)
  after_contract_breach :contract_breached

  def perform
    sleep 2
  end

  private

  def contract_breached(contract)
    # TODO: notify error monitoring service
    Rails.logger.info "Contract violation! #{contract.inspect}"
  end
end
