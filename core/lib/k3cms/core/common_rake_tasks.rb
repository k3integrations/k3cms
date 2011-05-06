#---------------------------------------------------------------------------------------------------
require 'bundler'
Bundler::GemHelper.install_tasks

#---------------------------------------------------------------------------------------------------
desc "Generates a Gemfile and then runs bundle install"
task :bundle, [:args] do |t, args|
  Rake::Task[:gemfile].invoke("#{args[:args]} --install")
end

#---------------------------------------------------------------------------------------------------
require 'rspec/core/rake_task'

desc 'Default: Run spec and cucumber'
task :default => [:spec, :cucumber ]

desc 'Run specdoc'
RSpec::Core::RakeTask.new('specdoc') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run specs'
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end
#---------------------------------------------------------------------------------------------------
