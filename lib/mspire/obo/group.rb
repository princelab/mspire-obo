require 'mspire/obo'
require 'mspire/obo/hash_provider'

module Mspire
  class Obo
    # An Mspire::Obo::Group is a distinct collection of Mspire::Obo objects,
    # but all lookup hashes are merged across the various ontologies.  This
    # means that a user can make a group and query across all the ontologies
    # in a single, simple call.  The interface mimics that of the hash
    # providing Mspire::Obo object.
    #
    #     group = Mspire::Obo::Group.new([Mspire::Obo[:ms], Mspire::Obo[:uo]])
    #     hash = group.id_to_name
    #     # can access any ids from the various Mspire::Obo objects
    #     hash["MS:1000001"] # -> 'sample number'
    #     group
    #
    class Group
      include Mspire::Obo::HashProvider

      # the array of Mspire::Obo objects
      attr_accessor :obos

      def initialize(obos=[])
        @obos = obos
      end

      # returns an id to name Hash
      def make_id_to_name
        merge_hashes(__method__)
      end

      def make_id_to_cast
        merge_hashes(__method__)
      end

      # returns an id_to_stanza hash
      def make_id_to_stanza
        merge_hashes(__method__)
      end

      # returns a name_to_id Hash
      def make_name_to_id
        merge_hashes(__method__)
      end

      # merges the hashes retrieved with that symbol
      def merge_hashes(symbol)
        obos.map(&symbol).reduce({}, :merge)
      end

      # creates a hash keyed by namespace string that yields the name_to_id
      # hash.
      def name_to_id_by_namespace
        Hash[ obos.map(&:namespace).zip(obos.map(&:make_name_to_id)) ]
      end

      # with no arguments, merely returns the @name_to_id merged hash (if
      # made).  With one argument, looks up the id given the name.  With a
      # namespace, the id will be returned without collision.
      def name_to_id(name=nil, namespace=nil)
        if namespace
          @name_to_id_by_namespace ||= name_to_id_by_namespace
          @name_to_id_by_namespace[namespace][name]
        elsif name
          @name_to_id[name]
        else
          @name_to_id
        end
      end

      undef_method(:build_hash)
    end
  end
end
