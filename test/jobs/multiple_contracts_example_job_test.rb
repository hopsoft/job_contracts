# frozen_string_literal: true

require "test_helper"

class MultipleContractsExampleJobTest < ActiveJob::TestCase
  test "contract breached" do
    perform_enqueued_jobs { MultipleContractsExampleJob.perform_later }
    assert_performed_jobs 1
    job = performed_jobs.first[:job]
    assert job.breached_contracts.size == 2
    assert job.breached_contracts.first.breached?
    assert job.breached_contracts.first.expect[:duration] == 1.second
    assert job.breached_contracts.first.actual[:duration] >= 1.second
    assert job.breached_contracts.second.breached?
    assert job.breached_contracts.second.actual.present?
    assert job.breached_contracts.second.actual[:error].start_with?("Write query attempted while in readonly mode")
  end
end
