require 'mspire/obo/version'
require 'mspire/obo/header_parser'
require 'obo'
require 'ext/obo'
require 'andand'
require 'yaml'

module Enumerable
  def index_by
    if block_given?
      Hash[map { |elem| [yield(elem), elem] }]
    else
      to_enum :index_by
    end
  end
end

module Mspire
  # This is the major class representing an ontology.  Because there are
  # multiple ways to access the information, and fast access requires building
  # a hash, you will need to explicitly build any hashes you want to use.
  #
  #     Mspire::Obo.new(file).make_all!
  class Obo

    DIR = File.expand_path(File.dirname(__FILE__) + '/../../obo')

    class << self
      # returns an array of hashes with each hash describing the available
      # obos (those in the Mspire::Obo::DIR directory) with these keys:
      #
      #     :full_name # the generic name of the ontology
      #     :uri       # where the ontology may be downloaded
      #     :namespace # namespace (String)
      #     :path      # the expanded path filename
      #     :version   # the ontology version (String)
      #     :key       # access symbol [typically namespace.downcase.to_sym] (Symbol)
      def available(index_by=nil)
        obos = []
        Dir.chdir(Mspire::Obo::DIR) do
          Dir['*.*'].sort.each_slice(2) do |meta, obo|
            hash = Hash[YAML.load_file(meta).map {|k,v| [k.to_sym, v] }]
            hash[:path] = File.expand_path(obo)
            hash[:version] = version(hash[:path])
            hash[:key] = hash[:namespace].downcase.to_sym
            obos << hash
          end
        end
        if index_by
          obos.index_by {|info| info[index_by] }
        else
          obos
        end
      end

      # returns an array of Obo objects corresponding to all obos held
      def all(load_file=true)
        available(:key).keys.map {|key| self[key, load_file] }
      end

      # determines the version of the obo by just reading the header
      def version(filename)
        self.new.set_version!(filename).version
      end

      # create an Mspire::Obo object from any obo file within the obo
      # directory using its :key.  The key is the downcased symbol of the
      # namespace and can effortlessly be determined with
      # Mspire::Obo.available().
      def [](key, load_file=true)
        lookup = available.index_by {|info| info[:key] }
        info = lookup[key]
        self.new(
          load_file ? info[:path] : nil,
          uri: info[:uri], 
          full_name: info[:full_name], 
          version: info[:version],
          path: info[:path]
        )
      end
    end


    attr_accessor :header
    attr_accessor :stanzas

    ## These are common attributes associated with typical usage of obo files
    ## (e.g. see mzML spec)

    # the uri of the obo file (required for most markup languages using
    # ontologies)
    attr_accessor :uri
    # the English name of the ontology (e.g., "Proteomics Ontology") (required
    # for most markup languages using ontologies)
    attr_accessor :full_name
    # the version of the file.  This can be found dynamically if you have the
    # file (required for most markup languages using ontologies)
    attr_accessor :version
    # expanded path to the obo file (optional)
    attr_accessor :path

    attr_reader :id_to_name
    attr_reader :id_to_cast
    attr_reader :id_to_stanza
    attr_reader :name_to_id

    # if given a filename, then the file will be read and relevant properties
    # will be set.
    def initialize(filename=nil, uri: nil, full_name: nil, version: nil, path: nil)
      @uri, @full_name, @version, @path = uri, full_name, version, path
      from_file(filename) if filename
    end

    # sets the object properties and returns self for chaining
    def from_file(filename)
      obo = ::Obo::Parser.new(filename)
      @stanzas = obo.elements.to_a
      @header = @stanzas.shift
      version_from_header!
      self
    end

    # sets the header attribut and returns self for chaining
    def set_header_from_file!(filename)
      @header = Mspire::Obo::HeaderParser.new.header(filename)
      self
    end

    # sets the version attribute from the header, returns self.
    def version_from_header!
      @version = [header.tagvalues['data-version'].first, 
       header.tagvalues['remark'].map {|str| str[/version\s*:\s*([^\s]+)/, 1] }.compact.first,
       header['date'].andand.split(' ').first
      ].compact.first
      self
    end

    # sets the version by just reading the header of the file.  Returns self for
    # chaining.
    def set_version!(filename)
      set_header_from_file!(filename).version_from_header!
    end

    # builds all hashes for fast access
    def make_all!
      id_to_name!.id_to_cast!.name_to_id!.id_to_stanza!
    end

    ####################
    ## ID TO CAST
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

    protected

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
