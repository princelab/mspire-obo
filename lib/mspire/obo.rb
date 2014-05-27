require 'mspire/obo/version'
require 'mspire/obo/header_parser'
require 'obo'
require 'ext/obo'
require 'andand'

module Mspire
  # This is the major class representing an ontology.  Because there are
  # multiple ways to access the information, and fast access requires building
  # a hash, you will need to explicitly build any hashes you want to use.
  #
  #     Mspire::Obo.new(file).build_all!
  class Obo

#    COMMON = %i(ms unit ims unimod mod)
    #INFO = {
      #ms: {
        #obo: 'ms.obo',
        #xml_id: 'MS',
        #full_name: "Proteomics Standards Initiative Mass Spectrometry Ontology", 
        #uri: "http://psidev.cvs.sourceforge.net/*checkout*/psidev/psi/psi-ms/mzML/controlledVocabulary/psi-ms.obo", 
        #version: "3.29.0",
      #},
      ##ims: {
        ##obo: ,
        ##xml_id: ,
        ##full_name: , 
        ##uri: , 
        ##version: ,
      ##},
      ##unit: {
        ##obo: ,
        ##xml_id: ,
        ##full_name: , 
        ##uri: , 
        ##version: ,
      ##},
      ##psimod: {
        ##obo: ,
        ##xml_id: ,
        ##full_name: , 
        ##uri: , 
        ##version: ,
      ##},
      ##unimod: {
        ##obo: ,
        ##xml_id: ,
        ##full_name: , 
        ##uri: , 
        ##version: ,
      ##},
    #}


    #class << self
      ### looks up the appropriate object based on the leader and returns the
      ### name.  For example, Mspire::Obo.name("UO:0000005") requires that
      ### Mspire::Obo::UO be an Mspire::Obo object (or at least something that
      ### can response to :name)
      ##def name(id)
        ##self.const_get( id.split(':',2).first.upcase ).name(id)
      ##end

      ### looks up the appropriate object based on the leader and returns a cast
      ### symbol (e.g., :to_f) or casts the value passed in.  for example,
      ### mspire::obo.cast("uo:0000005") requires that mspire::obo::uo be an
      ### mspire::obo object (or at least something that can respond to :cast)
      ##def cast(id, val=nil)
        ##self.const_get( id.split(':',2).first.upcase ).cast(id, val)
      ##end

      ## returns an mspire::obo object with information, but that has not read
      ## the obo file.
      #def info(key)
      #end

      #def obo(key)
      #end
    #end

    DIR = File.expand_path(File.dirname(__FILE__) + '/../../obo')

    attr_accessor :header
    attr_accessor :stanzas

    ## These are common attributes associated with typical usage of obo files
    ## (e.g. see mzML spec)

    attr_accessor :uri
    attr_accessor :full_name
    attr_accessor :version

    # if given a filename, then the file will be read and relevant properties
    # will be set.
    def initialize(filename=nil, uri: nil, full_name: nil, version: nil)
      @uri, @full_name, @version, @xml_id = uri, full_name, version 
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
    def build_all!
      id_to_name!.id_to_cast!.name_to_id!.id_to_stanza!
    end

    # requires id_to_name! be called first
    def name(id)
      @id_to_name[id]
    end

    # builds the hash and returns self for chaining
    def id_to_name!
      self
    end

    # returns an id to name Hash
    def id_to_name
      build_hash('id', 'name')
    end

    # creates an id_to_cast 
    def id_to_cast!
      @id_to_cast = id_to_cast
      self
    end

    def id_to_cast
      @id_to_stanza ||= id_to_stanza
      Hash[ @id_to_stanza.map {|id,el| [id, el.cast_method] } ]
    end

    # requires id_to_cast! be called first.  If no val given, returns a symbol (e.g., :to_f).  If given a val, then it returns the cast of that val.
    def cast(id, val=nil)
      val ? val.send(@id_to_cast[id]) : @id_to_cast[id]
    end

    # builds the name_to_id hash and returns self for chaining
    def name_to_id!
      @name_to_id = name_to_id
      self
    end

    # returns a name_to_id Hash
    def name_to_id
       build_hash('name', 'id')
    end

    # builds an internal id_to_stanza hash and returns self
    def id_to_stanza!
      @id_to_stanza = id_to_stanza
      self
    end

    # returns an id_to_stanza hash
    def id_to_stanza
      build_hash('id', nil)
    end

    # returns an Obo::Stanza object
    def stanza(id)
      @id_to_stanza[id]
    end

    protected
    def build_hash(key,val)
      hash = {}
      stanzas.each do |el| 
        tv = el.tagvalues
        if val.nil?
          hash[tv[key].first] = el
        else
          hash[tv[key].first] = tv[val].first
        end
      end
      hash
    end
  end
end
