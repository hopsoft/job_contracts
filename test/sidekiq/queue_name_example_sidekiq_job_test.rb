# frozen_string_literal: true

require "sidekiq/testing"
require "test_helper"

class QueueNameExampleSidekiqJobTest < Minitest::Test
  def test_job_class_exists
    assert QueueNameExampleSidekiqJob
  end
end
