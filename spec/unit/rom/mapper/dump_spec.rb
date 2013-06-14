require 'spec_helper'

describe Mapper, '#dump' do
  subject(:mapper) { described_class.new(header, model) }

  let(:header) { Mapper::Header.coerce([[:uid, Integer ], [:name, String]], :map => { :uid => :id }) }
  let(:tuple)  { Hash[uid: 1, name: 'Jane'] }
  let(:data)   { [1, 'Jane'] }
  let(:object) { model.new(id: 1, name: 'Jane') }
  let(:model)  { mock_model(:id, :name) }

  it 'dumps the object into tuple data' do
    expect(mapper.dump(object)).to eq(data)
  end
end
