
desc "Set up environment to play with gem state..."
task :spike => [:update, :play]

task :update do
  `gem uninstall wdi -x --force`
  Rake::Task["build"].execute
  `gem install #{File.expand_path("pkg/wdi-#{WDI::VERSION}.gem")}`
end

task :play do
  require "wdi"
  require "pry"

  include WDI::Config
  include WDI::Directory

  binding.pry
end
