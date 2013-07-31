shared_examples_for 'Mapper::Loader#identity' do
  subject(:loader) { described_class.new(header, model) }

  let(:header) { Mapper::Header.build([[:id, Integer ], [:name, String]], :keys => [:id]) }
  let(:tuple)  { Hash[id: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }

  it "returns object's identity" do
    expect(loader.identity(tuple)).to eq([1])
  end
end
