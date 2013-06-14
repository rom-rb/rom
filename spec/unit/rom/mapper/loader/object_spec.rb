require 'spec_helper'

describe Mapper::Loader, '#object' do
  subject(:loader) { described_class.new(header, model, tuple) }

  let(:header) { Mapper::Header.coerce([[:uid, Integer ], [:name, String]], :map => { :uid => :id }, :keys => [ :uid ]) }
  let(:tuple)  { Hash[uid: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }

  it "returns loaded object" do
    expect(loader.object).to eq(model.new(id: 1, name: 'Jane'))
  end
end
