# frozen_string_literal: true

require "test_helper"

class ReadOnlyExampleJobTest < ActiveJob::TestCase
  test "contract breached" do
    perform_enqueued_jobs { ReadOnlyExampleJob.perform_later }
    assert_performed_jobs 1
    job = performed_jobs.first[:job]
    breached_contracts = job.breached_contracts.to_a
    assert breached_contracts.size == 1
    assert breached_contracts.first.breached?
    assert breached_contracts.first.actual[:error].start_with?("Write query attempted while in readonly mode")
  end

  test "contract satisfied when run on a different queue" do
    perform_enqueued_jobs { ReadOnlyExampleJob.set(queue: :low).perform_later }
    assert_performed_jobs 1
    job = performed_jobs.first[:job]
    assert job.breached_contracts.blank?
  end
end
