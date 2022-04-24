# frozen_string_literal: true

require "test_helper"

class QueueNameExampleJobTest < ActiveJob::TestCase
  test "contract not breached" do
    perform_enqueued_jobs { QueueNameExampleJob.perform_later }
    assert_performed_jobs 1
    assert performed_jobs.first[:breached_contracts].blank?
  end

  # TODO: figure out how to keep the test framework happy when reenqueueing due to contract breach
  #       currently get this error when the reenqueue happens:
  #         RuntimeError: can't add a new key into hash during iteration
  # test "contract breached" do
  #   perform_enqueued_jobs { QueueNameExampleJob.set(queue: :default).perform_later }

  #   #assert_performed_jobs 2

  #   #assert performed_jobs.first[:breached_contracts].size == 1
  #   #assert performed_jobs.first[:breached_contracts].first.breached?
  #   #assert performed_jobs.first[:breached_contracts].first.expect[:queue_name].to_s == "low"
  #   #assert performed_jobs.first[:breached_contracts].first.actual[:queue_name] >= "default"

  #   #assert performed_jobs.last[:breached_contracts].blank?
  # end
end
