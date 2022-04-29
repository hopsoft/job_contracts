# frozen_string_literal: true

require "test_helper"

class QueueNameExampleJobTest < ActiveJob::TestCase
  test "contract not breached" do
    perform_enqueued_jobs { QueueNameExampleJob.perform_later }
    assert_performed_jobs 1

    job = performed_jobs.first[:job]
    assert job.breached_contracts.blank?
  end

  test "contract breached" do
    perform_enqueued_jobs { QueueNameExampleJob.set(queue: :default).perform_later }

    assert_performed_jobs 1
    job = performed_jobs.first[:job]
    assert job.breached_contracts.size == 1
    assert job.breached_contracts.first.breached?
    assert job.breached_contracts.first.expected[:queue_name].to_sym == :low
    assert job.breached_contracts.first.actual[:queue_name].to_sym == :default
    assert job.enqueues.size == 1
    assert job.enqueues.first[:queue] == :low
  end
end
