# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in job_contracts.gemspec.
gemspec

gem "rails", ENV["RAILS_VERSION"] if ENV["RAILS_VERSION"]

gem "sqlite3"

gem "sidekiq", ENV["SIDEKIQ_VERSION"] if ENV["SIDEKIQ_VERSION"]

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
