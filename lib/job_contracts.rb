require "job_contracts/version"
require "job_contracts/railtie"

root = Pathname.new(File.dirname(File.absolute_path(__FILE__)))
root.glob("**/*.rb").each { |file| require file }

module JobContracts
  # Your code goes here...
end
