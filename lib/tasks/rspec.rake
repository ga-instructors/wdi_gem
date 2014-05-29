require 'rspec/core/rake_task'

desc 'Run Rspec specs (unit tests)'
task :specs => [:units]

RSpec::Core::RakeTask.new(:units) do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

# desc "Generate code coverage"
# RSpec::Core::RakeTask.new(:coverage) do |t|
#   t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
# end
