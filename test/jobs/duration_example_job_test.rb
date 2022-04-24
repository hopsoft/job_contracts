# frozen_string_literal: true

require "test_helper"

class DurationExampleJobTest < ActiveJob::TestCase
  test "contract breached" do
    perform_enqueued_jobs { DurationExampleJob.perform_later }
    assert_performed_jobs 1
    assert performed_jobs.first[:breached_contracts].size == 1
    assert performed_jobs.first[:breached_contracts].first.breached?
    assert performed_jobs.first[:breached_contracts].first.expect[:duration] == 1.second
    assert performed_jobs.first[:breached_contracts].first.actual[:duration] >= 1.second
  end
end
