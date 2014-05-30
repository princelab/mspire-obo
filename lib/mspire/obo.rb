require 'mspire/obo/version'
require 'mspire/obo/header_parser'
require 'mspire/obo/hash_provider'
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
    include Mspire::Obo::HashProvider

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
          path: info[:path],
          namespace: info[:namespace],
        )
      end
    end


    attr_accessor :header
    attr_accessor :stanzas

    ## These are common attributes associated with typical usage of obo files
    ## (e.g. see mzML spec)

    # String specifying the namespace of the obo, e.g., 'UO' for unit
    # ontology, "IMS" for imaging mass spec.  (necessary for name_to_id
    # collision resolution for Mspire::Obo::Group objects).
    attr_accessor :namespace
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

    # if given a filename, then the file will be read and relevant properties
    # will be set.
    def initialize(filename=nil, uri: nil, full_name: nil, version: nil, path: nil, namespace: nil)
      @uri, @full_name, @version, @path, @namespace = uri, full_name, version, path, namespace
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
  end
end
