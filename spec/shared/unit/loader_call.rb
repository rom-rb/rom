shared_examples_for 'Mapper::Loader#call' do
  subject(:loader) { described_class.new(header, model) }

  let(:header) { Mapper::Header.build([[:id, Integer ], [:name, String]]) }
  let(:tuple)  { Hash[id: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }

  it 'returns loaded object' do
    expect(loader.call(tuple)).to eq(model.new(id: 1, name: 'Jane'))
  end
end
