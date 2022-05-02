# frozen_string_literal: true

require "test_helper"

class DurationExampleJobTest < ActiveJob::TestCase
  test "contract breached" do
    perform_enqueued_jobs { DurationExampleJob.perform_later }
    assert_performed_jobs 1
    job = performed_jobs.first[:job]
    breached_contracts = job.breached_contracts.to_a
    assert breached_contracts.size == 1
    assert breached_contracts.first.breached?
    assert breached_contracts.first.expected[:max] == 1.second
    assert breached_contracts.first.actual[:duration] >= 1.second
  end
end
