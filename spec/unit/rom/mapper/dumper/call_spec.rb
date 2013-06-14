require 'spec_helper'

describe Mapper::Dumper, '#identity' do
  subject(:result) { described_class.new(header, model, object).call }

  let(:header) { Mapper::Header.coerce([[:uid, Integer ], [:name, String]], :map => { :uid => :id }, :keys => [ :uid ]) }
  let(:data)   { Hash[id: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }
  let(:object) { model.new(data) }

  describe 'result' do
    it "has object's identity" do
      expect(result.identity).to eq([1])
    end

    it "has dumped tuple" do
      expect(result.tuple).to eq([1, 'Jane'])
    end
  end
end
