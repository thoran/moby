# Rakefile

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
  t.warning = false
end

task default: :test

desc "Run tests"
task :spec => :test

desc "Show version"
task :version do
  require_relative './lib/Moby/VERSION'
  puts "moby #{Moby::VERSION}"
end
