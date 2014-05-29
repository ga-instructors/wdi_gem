require "cucumber/rake/task"

desc "Run all feature tests"
task :test => [:features]

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['features', '-x', '--format progress']
end
