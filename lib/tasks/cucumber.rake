require "cucumber/rake/task"

desc "Run all feature tests"
task :features => [:features]

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['features', '-x', '--format progress']
end
