require "bundler/gem_tasks"
require 'tempfile'

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
  require 'mspire/obo'
  require 'open-uri'
  Mspire::Mzml.all(false).each do |obo|
    begin
      puts "working on #{File.basename(obo.uri)}"
      tmpfile = Tempfile.new("test_temp")
      tmpfile << open(obo.uri, &:read).gsub(/\r\n?/, "\n"))
      tmpfile.close
      if obo.version != Mspire::Obo.version(tmpfile)
        File.rename(tmpfile.path, obo.path)  
      end
    ensure
      if File.exist?(tmpfile.path)
        tmpfile.close!
      end
    end
    puts "NOTE: if a file changed (git status), then update lib/mspire/obo/<OBO>.rb with correct version !!!"
  end
end

