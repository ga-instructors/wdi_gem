require "bundler"
require "pry"

Bundler.setup

Dir[File.expand_path('../../lib/wdi/*.rb', __FILE__)].each {|file| require file }

RSpec.configure do |config|
  config.color = true
  config.formatter = "documentation"
end