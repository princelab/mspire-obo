require 'spec_helper'
require 'mspire/obo'
require 'mspire/obo/header_parser'


describe Mspire::Obo::HeaderParser do
  let(:obo_file) { Mspire::Obo::DIR + "/unit.obo" }

  it 'reads headers from obo files' do
    header = described_class.new.header(obo_file)
    {"format-version"=>["1.2"], "date"=>["12:10:2011 11:21"], "saved-by"=>["George Gkoutos"], "auto-generated-by"=>["OBO-Edit 2.1-beta13"], "subsetdef"=>["unit_group_slim \"unit group slim\"", "unit_slim \"unit slim\""], "default-namespace"=>["unit.ontology"], "namespace-id-rule"=>["* UO:$sequence(7,0,9999999)$"], "import"=>["http://purl.obolibrary.org/obo/pato.obo"]}.each do |key, expect|
      expect(header.tagvalues[key]).to eq expect
    end
  end

end
