# frozen_string_literal: true

module JobContracts
  class SidekiqJobHashMiddleware
    def call(worker, job, queue)
      worker.instance_variable_set :@sidekiq_job_hash, job
      yield
    end
  end
end
