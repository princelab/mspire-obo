require 'spec_helper'

require 'mspire/obo/ms'
require 'mspire/obo/ims'
require 'mspire/obo/unit'
require 'mspire/obo/mod'

describe 'accessing a specific Obo::Ontology' do

  it 'can access MS obo' do
    Mspire::Obo::MS.id_to_name['MS:1000004'].should == 'sample mass'
    Mspire::Obo::MS.name_to_id['sample mass'].should == 'MS:1000004'
    Mspire::Obo::MS.id_to_element['MS:1000004'].should be_a(Obo::Stanza)
  end

  it 'can access IMS obo' do
    Mspire::Obo::IMS.id_to_name['IMS:1000004'].should == 'image'
    Mspire::Obo::IMS.name_to_id['image'].should == 'IMS:1000004'
    Mspire::Obo::IMS.id_to_element['IMS:1000004'].should be_a(Obo::Stanza)
  end

  it 'can access Unit obo' do
    Mspire::Obo::Unit.id_to_name['UO:0000005'].should == 'temperature unit'
    Mspire::Obo::Unit.name_to_id['temperature unit'].should == 'UO:0000005'
    Mspire::Obo::Unit.id_to_element['UO:0000005'].should be_a(Obo::Stanza)
  end

end

describe 'Obo::Stanza' do
  it 'can properly cast values' do
    Mspire::Obo::MS.id_to_element['MS:1000511'].cast('1').should == 1
    Mspire::Obo::MS.id_to_element['MS:1000004'].cast('2.2').should == 2.2
    # don't ask me why mass resolution is cast into a string, but it is!
    Mspire::Obo::MS.id_to_element['MS:1000011'].cast('2.2').should == '2.2'
    Mspire::Obo::MS.id_to_element['MS:1000018'].cast('low to high').should == 'low to high'
  end
end
