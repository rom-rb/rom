require 'spec_helper'

describe Mapper, '#load' do
  subject(:mapper) { described_class.new(header) }

  let(:header) { Axiom::Relation::Header.coerce([[:id, Integer ], [:name, String]]) }
  let(:tuple)  { Hash[id: 1, name: 'Jane'] }

  it 'loads the tuple into model' do
    expect(mapper.load(tuple)).to eq(OpenStruct.new(tuple))
  end
end
