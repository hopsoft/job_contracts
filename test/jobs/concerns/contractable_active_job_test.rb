# frozen_string_literal: true

module ContractableActiveJobTest
  def contract_breached(contract)
    super
    job_metadata = queue_adapter.performed_jobs.find do |payload|
      payload["job_id"] == job_id
    end
    job_metadata ||= {}
    job_metadata[:breached_contracts] ||= []
    job_metadata[:breached_contracts] << contract
  end
end
