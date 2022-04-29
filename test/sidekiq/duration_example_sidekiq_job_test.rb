# frozen_string_literal: true

require "sidekiq/testing"
require "test_helper"

class DurationExampleSidekiqJobTest < Minitest::Test
  def test_job_class_exists
    assert DurationExampleSidekiqJob
  end
end
