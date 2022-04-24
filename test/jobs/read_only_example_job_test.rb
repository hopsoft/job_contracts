# frozen_string_literal: true

require "test_helper"

class ReadOnlyExampleJobTest < ActiveJob::TestCase
  test "contract breached" do
    perform_enqueued_jobs { ReadOnlyExampleJob.perform_later }
    assert_performed_jobs 1
    assert performed_jobs.first[:breached_contracts].size == 1
    assert performed_jobs.first[:breached_contracts].first.breached?
    assert performed_jobs.first[:breached_contracts].first.expect.blank?
    assert performed_jobs.first[:breached_contracts].first.actual.present?
    assert performed_jobs.first[:breached_contracts].first.actual[:error].start_with?("Write query attempted while in readonly mode")
  end
end
