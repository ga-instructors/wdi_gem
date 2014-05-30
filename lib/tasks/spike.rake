
desc "Set up environment to play with gem state..."
task :spike => [:update, :play]

task :update do
  `gem uninstall wdi -x --force`
  Rake::Task["build"].execute
  `gem install #{File.expand_path("pkg/wdi-#{WDI::VERSION}.gem")}`
end

task :play do
  require "wdi/configuration"
  require "pry"

  include WDI::Configuration

  binding.pry
end
