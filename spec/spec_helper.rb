require "bundler"
require "pry"

Bundler.setup

Dir[File.expand_path('../../lib/wdi/*.rb', __FILE__)].each {|file| require file }

RSpec.configure do |config|
  config.filter_run_excluding unnecessary: true
  config.filter_run_excluding broken: true

  config.color = true
  config.formatter = "documentation"
end