# frozen_string_literal: true

require "test_helper"

class MultipleContractsExampleJobTest < ActiveJob::TestCase
  test "contract breached" do
    perform_enqueued_jobs { MultipleContractsExampleJob.perform_later }
    assert_performed_jobs 1
    job = performed_jobs.first[:job]
    breached_contracts = job.breached_contracts.to_a
    assert breached_contracts.size == 2
    assert breached_contracts.first.breached?
    assert breached_contracts.first.expected[:duration] == 1.second
    assert breached_contracts.first.actual[:duration] >= 1.second
    assert breached_contracts.second.breached?
    assert breached_contracts.second.actual.present?
    assert breached_contracts.second.actual[:error].start_with?("Write query attempted while in readonly mode")
  end
end
