require 'bundler'
Bundler::GemHelper.install_tasks

#---------------------------------------------------------------------------------------------------
require 'rspec/core/rake_task'

desc 'Default: Run specs'
task :default => :spec

desc 'Run specdoc'
RSpec::Core::RakeTask.new('specdoc') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run specs'
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end


