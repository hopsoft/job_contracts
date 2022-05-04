# frozen_string_literal: true

require "sidekiq"
require_relative "sidekiq_job_hash_middleware"

module JobContracts
  class Railtie < ::Rails::Railtie
    initializer "job_contracts.register_sidekiq_middleware" do
      Sidekiq.server_middleware.add SidekiqJobHashMiddleware
    end
  end
end
