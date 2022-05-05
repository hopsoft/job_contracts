# frozen_string_literal: true

require_relative "lib/job_contracts/version"

Gem::Specification.new do |spec|
  spec.name = "job_contracts"
  spec.version = JobContracts::VERSION
  spec.authors = ["Nathan Hopkins"]
  spec.email = ["natehop@gmail.com"]
  spec.homepage = "https://github.com/hopsoft/job_contracts"
  spec.summary = "Enforceable contracts for jobs"
  spec.description = "Enforceable contracts for jobs"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hopsoft/job_contracts"
  spec.metadata["changelog_uri"] = "https://github.com/hopsoft/job_contracts/releases"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.1.5"
  spec.add_dependency "sidekiq", ">= 6.4.2"

  spec.add_development_dependency "standard"
  spec.add_development_dependency "magic_frozen_string_literal"
  spec.add_development_dependency "pry-rails"
  spec.add_development_dependency "pry-doc"
  spec.add_development_dependency "tocer"
end
