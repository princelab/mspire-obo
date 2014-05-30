module Mspire
  class Obo
    # requires classes to provide the :stanzas method
    module HashProvider

      attr_reader :id_to_stanza
      attr_reader :id_to_name
      attr_reader :id_to_cast
      attr_reader :name_to_id

      # builds all hashes for fast access
      def make_all!
        id_to_name!.id_to_cast!.id_to_stanza!.name_to_id!
      end

      ####################
      ## ID TO STANZA
      ####################

      # returns an id_to_stanza hash
      def make_id_to_stanza
        build_hash('id', nil)
      end

      # makes and sets the id_to_stanza hash and returns self
      def id_to_stanza!
        @id_to_stanza = make_id_to_stanza
        self
      end

      # returns an Obo::Stanza object
      def stanza(id)
        @id_to_stanza[id]
      end

      ####################
      ## ID TO NAME
      ####################

      # returns an id to name Hash
      def make_id_to_name
        build_hash('id', 'name')
      end

      # builds the id_to_name hash and returns self for chaining
      def id_to_name!
        @id_to_name = make_id_to_name
        self
      end

      # requires id_to_name! be called first
      def name(id)
        @id_to_name[id]
      end

      ####################
      ## ID TO CAST
      ####################

      def make_id_to_cast
        build_hash('id', :cast_method)
      end

      # makes and sets the id_to_cast hash
      def id_to_cast!
        @id_to_cast = make_id_to_cast
        self
      end

      # requires id_to_cast! be called first.  If no val given, returns a symbol (e.g., :to_f).  If given a val, then it returns the cast of that val.
      def cast(id, val=nil)
        val ? val.send(@id_to_cast[id]) : @id_to_cast[id]
      end

      ####################
      ## NAME TO ID
      ####################

      # makes and sets the name_to_id hash and returns self
      def name_to_id!
        @name_to_id = make_name_to_id
        self
      end

      # returns a name_to_id Hash
      def make_name_to_id
        build_hash('name', 'id')
      end

      ####################
      ####################
      
      # if val is a symbol, will call that method on the stanza
      def build_hash(key,val)
        hash = {}
        stanzas.each do |el|
          tv = el.tagvalues
          case val
          when nil
            hash[tv[key].first] = el
          when Symbol
            hash[tv[key].first] = (el.send(val))
          else
            hash[tv[key].first] = tv[val].first
          end
        end
        hash
      end
    end
  end
end
