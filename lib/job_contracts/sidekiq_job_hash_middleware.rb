# frozen_string_literal: true

module JobContracts
  class SidekiqJobHashMiddleware
    include Sidekiq::ServerMiddleware if defined?(Sidekiq::ServerMiddleware)

    def call(worker, job, _queue)
      worker.instance_variable_set :@sidekiq_job_hash, job
      yield
    end
  end
end
