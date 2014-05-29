require 'spec_helper'

require 'mspire/obo'


describe Mspire::Obo do 

  let(:bases) { %w(psi-ms unit imagingMS PSI-MOD quality) }
  let(:filename) { Hash[bases.map {|base| [base, Mspire::Obo::DIR + "/#{base}.obo"] }] }

  let(:normal) { /\A[\d\.]{5,10}\Z/ }# "0.9.1" or "0.91.132"
  let(:date) { /\A[\d:]{8,15}\Z/ } # "09:04:2014"

  describe 'the Mspire::Obo class' do
    specify '#version(filename) returns the version' do
      expect(Mspire::Obo.version(filename['psi-ms'])).to match(normal)
    end
    specify '#available returns an informative hash for each obo' do
      hashes = Mspire::Obo.available
      hashes.each {|hash| expect(hash.keys.sort).to eq [:full_name, :url, :namespace, :path, :version, :key].sort }
      ms_hash = hashes.find {|hash| hash[:namespace] == 'MS' }
      expect(ms_hash[:full_name].split(' ').first).to eq('Proteomics')
      expect(ms_hash[:url]).to match(/psidev.*psi-ms.obo/)
      expect(ms_hash[:namespace]).to eq "MS"
      expect(ms_hash[:path]).to match(/.+obo\/psi-ms.obo/)
      expect(ms_hash[:version]).to match normal
      expect(ms_hash[:key]).to eq :ms
    end
  end

  it 'can set the version from a file (only reads the header)' do
    versions = bases.map do |base|
      Mspire::Obo.new.set_version!(filename[base]).version
    end
    [normal, date, normal, normal, date].zip(versions) do |exp_re, act|
      expect(act).to match(exp_re)
    end
  end

  context 'accessing ontology information from a file' do
    let(:obo) { Mspire::Obo.new(filename['psi-ms']) }

    describe 'Obo::Stanza' do
      it 'can properly cast values' do
        hash = obo.make_id_to_stanza
        expect(hash.size > 10).to eq true # check for the hash
        {
          'MS:1000511' => ['1', 1],
          'MS:1000004' => ['2.2', 2.2],
          'MS:1000011' => ['2.2', '2.2'],
          'MS:1000018' => ['low to high', 'low to high'],
        }.each do |id, vals|
          expect( hash[id].cast(vals.first) ).to eq(vals.last)
        end
      end
    end

    it 'has no uri or full_name unless provided' do
      expect([:uri, :full_name].map {|attr| obo.send(attr) }).to eq [nil,nil]
    end

    it 'automatically sets a version from the header information' do
      normal = /\A[\d\.]{5,10}\Z/
      expect(obo.version).to match(normal)
    end

    describe 'attr_accessor methods require hashes be built first' do
      describe 'attr_accessor methods for hashes before building' do
        specify 'they all yield nil' do
          expect([obo.id_to_name, obo.id_to_cast, obo.id_to_stanza, obo.name_to_id]).to eq [nil].*(4)
        end
      end

      it 'yields a hash if properly initialized' do
        [obo.id_to_stanza!.id_to_stanza, 
         obo.id_to_name!.id_to_name,
         obo.id_to_cast!.id_to_cast,
         obo.name_to_id!.name_to_id].each do |hash|
           expect(hash.class).to eq Hash
         end
      end
    end

    describe 'methods returning hashes' do
      specify '#make_id_to_name' do
        hash = obo.make_id_to_name
        expect(hash.class).to eq Hash
        expect(hash['MS:1000005']).to eq 'sample volume'
      end
      specify '#make_id_to_cast' do
        hash = obo.make_id_to_cast
        expect(hash.class).to eq Hash
        expect(hash['MS:1000511']).to eq :to_i
        expect(hash['MS:1000004']).to eq :to_f
        expect(hash['MS:1000018']).to eq false
        expect(hash['MS:1000032']).to eq :to_s
      end
      specify '#make_name_to_id' do
        hash = obo.make_name_to_id
        expect(hash.class).to eq Hash
        expect(hash['ProteinProspector']).to eq 'MS:1002043'
      end
      specify '#make_id_to_stanza' do
        hash = obo.make_id_to_stanza
        expect(hash.class).to eq Hash
        stanza = hash['MS:1001994']
        expect(stanza.class).to eq Obo::Stanza
        expect(stanza['name']).to eq('top hat baseline reduction')
      end
    end
  end

end




#describe 'accessing a specific Obo::Ontology' do
#it 'can access MS obo' do
#Mspire::Obo::MS.id_to_name['MS:1000004'].should == 'sample mass'
#Mspire::Obo::MS.name_to_id['sample mass'].should == 'MS:1000004'
#Mspire::Obo::MS.id_to_element['MS:1000004'].should be_a(Obo::Stanza)
#end

#it 'can access IMS obo' do
#Mspire::Obo::IMS.id_to_name['IMS:1000004'].should == 'image'
#Mspire::Obo::IMS.name_to_id['image'].should == 'IMS:1000004'
#Mspire::Obo::IMS.id_to_element['IMS:1000004'].should be_a(Obo::Stanza)
#end

#it 'can access Unit obo' do
#Mspire::Obo::Unit.id_to_name['UO:0000005'].should == 'temperature unit'
#Mspire::Obo::Unit.name_to_id['temperature unit'].should == 'UO:0000005'
#Mspire::Obo::Unit.id_to_element['UO:0000005'].should be_a(Obo::Stanza)
#end
#end


