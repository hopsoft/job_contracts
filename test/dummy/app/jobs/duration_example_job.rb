# frozen_string_literal: true

class DurationExampleJob < ApplicationJob
  include JobContracts::Contractable

  queue_as :default
  add_contract JobContracts::DurationContract.new(max: 1.second)

  def perform(seconds = 2)
    sleep seconds
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.to_h.inspect}"
  end
end
