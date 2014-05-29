
desc "Set up environment to play with gem state..."
task :spike => [:reset, :play]

task :reset do
  `gem uninstall wdi -x --force`
  `rake build`
  `gem install pkg/wdi-0.0.4.gem`
end

task :play do
  require "wdi"
  require "pry"

  include WDI::Config
  include WDI::Directory

  binding.pry
end
