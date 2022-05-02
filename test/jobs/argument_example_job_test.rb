# frozen_string_literal: true

require "test_helper"

class ArgumentExampleJobTest < ActiveJob::TestCase
  test "contract satisfied" do
    perform_enqueued_jobs { ArgumentExampleJob.perform_later(5) }
    assert_performed_jobs 1
    job = performed_jobs.first[:job]
    breached_contracts = job.breached_contracts.to_a
    refute breached_contracts.present?
  end

  test "contract breached" do
    perform_enqueued_jobs { ArgumentExampleJob.perform_later(15) }
    assert_performed_jobs 1
    job = performed_jobs.first[:job]
    breached_contracts = job.breached_contracts.to_a
    assert breached_contracts.present?
  end
end
