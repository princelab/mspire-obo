
require 'mspire/obo/ms'
require 'mspire/obo/ims'
require 'mspire/obo/unit'

module Mspire
  module CV
    module Obo

      # a hash keyed on ID that gives the cv term name
      NAME = %w(MS IMS Unit).inject({}) do |hash,key|
        hash.merge! ::Obo.const_get(key).id_to_name 
      end
      # a hash keyed on namespace linking to a hash keyed by the accession
      # returning the proper casting method as a symbol (e.g. :to_f)
      CAST = %w(MS IMS Unit).inject({}) do |hash,key|
        hash.merge! ::Obo.const_get(key).id_to_cast
      end

    end
  end
end
