require 'spec_helper'

require 'mspire/obo'

describe Mspire::Obo do 

  base = %i{ms ims mod unit}
  let(:filename) { Hash[base.map {|base| [base, Mspire::Obo::DIR + "/#{base}.obo"] }] }

  it 'can set the version from a file (only reads the header)' do
    expected = ["3.29.0", "12:10:2011", "0.9.1", "1.010.7"]
    versions = [:ms, :unit, :ims, :mod].map do |base|
      Mspire::Obo.new.set_version!(filename[base]).version
    end
    expect(versions).to eq(expected)
  end

  context 'accessing ontology information from a file' do
    let(:obo) { Mspire::Obo.new(filename[:ms]) }

    describe 'Obo::Stanza' do
      it 'can properly cast values' do
        hash = obo.id_to_stanza
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
      expect(obo.version).to eq "3.29.0"
    end
    describe 'methods returning hashes' do
      specify '#id_to_name' do
        hash = obo.id_to_name
        expect(hash.class).to eq Hash
        expect(hash['MS:1000005']).to eq 'sample volume'
      end
      specify '#id_to_cast' do
        hash = obo.id_to_cast
        expect(hash.class).to eq Hash
        expect(hash['MS:1000511']).to eq :to_i
        expect(hash['MS:1000004']).to eq :to_f
        expect(hash['MS:1000018']).to eq false
        expect(hash['MS:1000032']).to eq :to_s
      end
      specify '#name_to_id' do
        hash = obo.name_to_id
        expect(hash.class).to eq Hash
        expect(hash['ProteinProspector']).to eq 'MS:1002043'
      end
      specify '#id_to_stanza' do
        hash = obo.id_to_stanza
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


