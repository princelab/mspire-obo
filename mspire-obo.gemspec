# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mspire/obo/version'

Gem::Specification.new do |spec|
  spec.name          = "mspire-obo"
  spec.version       = Mspire::Obo::VERSION
  spec.authors       = ["John T. Prince"]
  spec.email         = ["jtprince@gmail.com"]
  spec.summary       = %q{simplified access for obo ontology files}
  spec.description   = %q{simplified access for obo ontology files.  Builds hashes for quick lookup of terms and finds version, etc.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  [
    ["obo", ">= 0.1.5"],
    ["andand", ">= 1.3.3"],
  ].each do |args|
    spec.add_dependency(*args)
  end

  [
    ["bundler", "~> 1.6.2"],
    ["rake"],
    ["rspec", "~> 2.14.1"], 
    ["rdoc", "~> 4.1.1"], 
    ["simplecov", "~> 0.8.2"],
  ].each do |args|
    spec.add_development_dependency(*args)
  end
end
