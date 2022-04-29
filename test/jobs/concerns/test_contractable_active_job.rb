# frozen_string_literal: true

require "monitor"

module TestContractableActiveJob
  extend ActiveSupport::Concern
  include MonitorMixin

  included do
    after_perform :save_job_to_metadata
  end

  private

  def metadata
    queue_adapter.performed_jobs.find do |payload|
      payload["job_id"] == job_id
    end
  end

  def save_job_to_metadata
    t = Thread.new do
      sleep 0.01
      synchronize do
        data = metadata || {}
        data[:job] = self
      end
    end
    t.join
  end
end
