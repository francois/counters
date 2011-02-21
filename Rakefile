require 'bundler'
Bundler::GemHelper.install_tasks

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new

  task :default => :spec
rescue LoadError
  warn "RSpec not available - Rake tasks not available"
  warn "Install rspec using: gem install rspec"
end
