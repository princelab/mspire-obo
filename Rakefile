require "bundler/gem_tasks"
require 'tempfile'
require 'fileutils'

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
  puts "Downloading the latest:"
  Mspire::Obo.all(false).each do |obo|
    begin
      print "    #{File.basename(obo.uri)} ... "
      tmpfile = Tempfile.new("test_temp")
      tmpfile << open(obo.uri, &:read).gsub(/\r\n?/, "\n")
      tmpfile.close
      new_version = Mspire::Obo.version(tmpfile)
      if obo.version != new_version
        puts "!! ---> updating from #{obo.version} to #{new_version} (check into git) <--- !!"
        FileUtils.mv(tmpfile.path, obo.path)  
      else
        puts "already latest."
      end
    ensure
      if File.exist?(tmpfile.path)
        tmpfile.close!
      end
    end
  end
end

