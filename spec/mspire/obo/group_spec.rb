require 'spec_helper'

require 'mspire/obo/group'

describe Mspire::Obo::Group do 

  let(:obos) { %i(ims uo).map {|key| Mspire::Obo[key] } }
  subject { Mspire::Obo::Group.new(obos) }

  it 'is built with Mspire::Obo objects' do
    expect(subject.obos).to eq(obos)
  end

  describe 'making individual hashes' do

    specify '#id_to_name! builds id_to_name meta hash' do
      expect(subject.id_to_name!.id_to_name["UO:0000012"]).to eq "kelvin"
      expect(subject.id_to_name!.id_to_name["IMS:1000013"]).to eq "unit"
    end

    specify '#id_to_cast! builds id_to_name meta hash' do
      expect(subject.id_to_cast!.id_to_cast["UO:0000012"]).to eq false
      expect(subject.id_to_cast!.id_to_cast["IMS:1001207"]).to eq :to_f
    end

    specify '#id_to_stanza! builds id_to_name meta hash' do
      expect(subject.id_to_stanza!.id_to_stanza["UO:0000012"].class).to eq Obo::Stanza
      expect(subject.id_to_stanza!.id_to_stanza["IMS:1001207"].class).to eq Obo::Stanza
    end

    specify '' do
      expect(subject.name_to_id!.name_to_id['kelvin']).to eq "UO:0000012"
      expect(subject.name_to_id!.name_to_id['unit']).to eq "UO:0000000"  # <- clobbered "IMS:1000013"
    end

    describe 'resolving collisions with name_to_id' do
      specify '#name_to_id allows lookup with namespace' do
        subject.name_to_id!
        expect(subject.name_to_id.class).to eq Hash
        expect(subject.name_to_id['unit']).to eq "UO:0000000"
        expect(subject.name_to_id('unit')).to eq "UO:0000000"
        expect(subject.name_to_id("unit", 'IMS')).to eq "IMS:1000013"
      end
    end
  end

  describe '#make_all! building all hashes' do
    let(:made) { subject.make_all! }

    it 'builds id_to_name' do
      expect(made.id_to_name["UO:0000012"]).to eq "kelvin"
      expect(made.id_to_name["IMS:1000013"]).to eq "unit"
    end

    it 'builds id_to_cast' do
      expect(made.id_to_cast["UO:0000012"]).to eq false
      expect(made.id_to_cast["IMS:1001207"]).to eq :to_f
    end

    it 'builds id_to_stanza' do
      expect(made.id_to_stanza["UO:0000012"].class).to eq Obo::Stanza
      expect(made.id_to_stanza["IMS:1001207"].class).to eq Obo::Stanza
    end

    it "builds name_to_id, clobbering early ids when names collide (later takes precedence)" do
      expect(made.name_to_id['kelvin']).to eq "UO:0000012"
      expect(made.name_to_id['unit']).to eq "UO:0000000"  # <- clobbered "IMS:1000013"
    end
  end

  
end
