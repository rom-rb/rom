shared_context 'Mapper' do
  let(:mapper) { described_class.new(loader, dumper) }

  let(:loader) { fake(:loader) { Mapper::Loader } }
  let(:dumper) { fake(:dumper) { Mapper::Dumper } }
  let(:data)   { [1, 'Jane'] }
  let(:tuple)  { Hash[uid: 1, name: 'Jane'] }
  let(:object) { model.new(id: 1, name: 'Jane') }
  let(:model)  { mock_model(:id, :name) }
end
