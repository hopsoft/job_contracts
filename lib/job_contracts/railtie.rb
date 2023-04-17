# frozen_string_literal: true

require "sidekiq"
require_relative "sidekiq_job_hash_middleware"

module JobContracts
  class Railtie < ::Rails::Railtie
    initializer "job_contracts.register_sidekiq_middleware" do
      Sidekiq.configure_server do |config|
        config.server_middleware do |chain|
          chain.add SidekiqJobHashMiddleware
        end
      end
    end
  end
end
