require 'spec_helper'

describe Mapper, '#dump' do
  subject(:mapper) { described_class.new(header, model) }

  let(:model)  { OpenStruct }
  let(:header) { Axiom::Relation::Header.coerce([[:id, Integer ], [:name, String]]) }
  let(:tuple)  { Hash[id: 1, name: 'Jane'] }
  let(:data)   { [1, 'Jane'] }
  let(:object) { model.new(tuple) }

  it 'dumps the object into tuple data' do
    expect(mapper.dump(object)).to eq(data)
  end
end
