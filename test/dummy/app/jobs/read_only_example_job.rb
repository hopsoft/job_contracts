# frozen_string_literal: true

class ReadOnlyExampleJob < ApplicationJob
  include JobContracts::Contractable

  queue_as :default

  add_contract JobContracts::ReadOnlyContract.new

  def perform
    User.create! name: "test"
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service
    Rails.logger.info "Contract breached! #{contract.inspect}"
  end
end
