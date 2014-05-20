require 'mspire/obo'

Mspire::Obo::COMMON.each {|file| require "mspire/obo/#{file}" }

