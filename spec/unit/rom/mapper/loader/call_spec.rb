require 'spec_helper'

describe Mapper::Loader, '#call' do
  subject(:result) { described_class.new(header, model, tuple).call }

  let(:header) { Mapper::Header.coerce([[:uid, Integer ], [:name, String]], :map => { :uid => :id }, :keys => [ :uid ]) }
  let(:tuple)  { Hash[uid: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }

  describe "result" do
    it "has object's identity" do
      expect(result.identity).to eq([1])
    end

    it "has loaded object" do
      expect(result.object).to eq(model.new(id: 1, name: 'Jane'))
    end
  end
end
