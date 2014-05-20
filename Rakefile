require "bundler/gem_tasks"

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rubabel #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "downloads the latest obo to appropriate spot"
task 'update' do
  require 'mspire/obo/all'
  require 'open-uri'
  Mspire::Mzml::ALL.each do |obo|
    obo_fn = obo.basename
    File.write(obo_fn, open(obo.uri, &:read).gsub(/\r\n?/, "\n"))
    puts "NOTE: if a file changed (git status), then update lib/mspire/obo/<OBO>.rb with correct version !!!"
  end
end

