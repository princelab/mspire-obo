module Mspire
  class Obo
    # An Mspire::Obo::Group is a distinct collection of Mspire::Obo objects,
    # but all lookup hashes are merged across the various ontologies.  This
    # means that a user can make a group and query across all the ontologies
    # in a single, simple call.  The interface mimics that of an Mspire::Obo
    # object.
    #
    #     group = Mspire::Obo::Group.new([Mspire::Obo[:ms], Mspire::Obo[:unit]])
    #     hash = group.id_to_name
    #     # can access any ids from the various Mspire::Obo objects
    #     hash["MS:1000001"] # -> 'sample number'
    #     hash["UO:000001"]
    #     group
    class Group
      # the array of Mspire::Obo objects
      attr_accessor :obos

      def initialize(obos=[])
        @obos = obos
      end

      # merges all hashes into a new hash
      def merge_hashes(hashes)
      end

    end
  end
end
