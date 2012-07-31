require 'rake'
require 'spec/rake/spectask'
require "bundler/gem_tasks"

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec']
end

task :default  => :spec
