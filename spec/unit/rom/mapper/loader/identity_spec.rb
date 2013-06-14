require 'spec_helper'

describe Mapper::Loader, '#identity' do
  subject(:loader) { described_class.new(header, model, tuple) }

  let(:header) { Mapper::Header.coerce([[:uid, Integer ], [:name, String]], :map => { :uid => :id }, :keys => [ :uid ]) }
  let(:tuple)  { Hash[uid: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }

  it "returns object's identity" do
    expect(loader.identity).to eq([1])
  end
end
