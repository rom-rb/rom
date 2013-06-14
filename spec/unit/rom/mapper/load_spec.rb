require 'spec_helper'

describe Mapper, '#load' do
  subject(:mapper) { described_class.new(header, model) }

  let(:header) { Axiom::Relation::Header.coerce([[:id, Integer ], [:name, String]]) }
  let(:tuple)  { Hash[id: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }

  it 'loads the tuple into model' do
    expect(mapper.load(tuple)).to eq(model.new(tuple))
  end
end
