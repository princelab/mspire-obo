require 'spec_helper'
require 'mspire/obo'
require 'mspire/obo/header_parser'


describe Mspire::Obo::HeaderParser do
  let(:obo_file) { Mspire::Obo::DIR + "/uo.obo" }

  it 'reads headers from obo files' do
    header = described_class.new.header(obo_file)
    p header
  end

end
