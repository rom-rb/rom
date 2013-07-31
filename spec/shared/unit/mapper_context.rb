shared_context 'Mapper' do
  let(:mapper) { described_class.new(header, loader, dumper) }

  let(:header) { fake(:header) { Mapper::Header } }
  let(:loader) { fake(:loader) { Mapper::Loader } }
  let(:dumper) { fake(:dumper) { Mapper::Dumper } }
  let(:data)   { [1, 'Jane'] }
  let(:tuple)  { Hash[id: 1, name: 'Jane'] }
  let(:object) { model.new(id: 1, name: 'Jane') }
  let(:model)  { mock_model(:id, :name) }
end
