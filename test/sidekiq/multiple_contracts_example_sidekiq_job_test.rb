# frozen_string_literal: true

require "sidekiq/testing"
require "test_helper"

class MultipleContractsExampleSidekiqJobTest < Minitest::Test
  def test_job_class_exists
    assert MultipleContractsExampleSidekiqJob
  end
end
