require 'spec_helper'

describe Mapper::Dumper, '#tuple' do
  subject(:dumper) { described_class.new(header, model, object) }

  let(:header) { Mapper::Header.coerce([[:uid, Integer ], [:name, String]], :map => { :uid => :id }, :keys => [ :uid ]) }
  let(:data)   { Hash[id: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }
  let(:object) { model.new(data) }

  it "returns object's identity" do
    expect(dumper.identity).to eq([1])
  end
end
