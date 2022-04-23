# frozen_string_literal: true

class ReadOnlyExampleJob < ApplicationJob
  include JobContracts::Contractable

  queue_as :default

  add_contract JobContracts::ReadOnlyContract.new
  after_contract_breach :contract_breached

  def perform
    User.create! name: "test"
  end

  private

  def contract_breached(contract)
    # TODO: notify error monitoring service
    Rails.logger.info "Contract violation! #{contract.inspect}"
  end
end
