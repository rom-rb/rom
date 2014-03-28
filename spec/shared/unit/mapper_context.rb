# encoding: utf-8

shared_context 'Mapper' do
  let(:mapper) { described_class.build([[:id, key: true], [:name]], model: model) }

  let(:header) { fake(:header) { Mapper::Header } }
  let(:data)   { [1, 'Jane'] }
  let(:tuple)  { Hash[id: 1, name: 'Jane'] }
  let(:object) { model.new(id: 1, name: 'Jane') }
  let(:model)  { mock_model(:id, :name) }
end
