# frozen_string_literal: true

require "sidekiq/testing"
require "test_helper"

class ReadOnlyExampleSidekiqJobTest < Minitest::Test
  def test_job_class_exists
    assert ReadOnlyExampleSidekiqJob
  end
end
