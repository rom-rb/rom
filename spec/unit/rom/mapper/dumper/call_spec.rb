require 'spec_helper'

describe Mapper::Dumper, '#call' do
  subject(:dumper) { described_class.new(header, model) }

  let(:header) { Mapper::Header.build([[:uid, Integer ], [:name, String]], :map => { :uid => :id }, :keys => [ :uid ]) }
  let(:data)   { Hash[id: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }
  let(:object) { model.new(data) }

  it "returns dumped tuple" do
    expect(dumper.call(object)).to eq([1, 'Jane'])
  end
end
