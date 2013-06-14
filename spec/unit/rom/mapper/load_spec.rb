require 'spec_helper'

describe Mapper, '#load' do
  subject(:mapper) { described_class.new(header, model) }

  let(:header) { Mapper::Header.coerce([[:uid, Integer ], [:name, String]], :map => { :uid => :id }) }
  let(:tuple)  { Hash[uid: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }

  it 'loads the tuple into model' do
    expect(mapper.load(tuple)).to eq(model.new(id: 1, name: 'Jane'))
  end
end
