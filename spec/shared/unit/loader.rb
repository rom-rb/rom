# encoding: utf-8

shared_examples_for 'Mapper::Loader' do
  subject(:loader) { described_class.new(header, model, transformer) }

  let(:header)      { Mapper::Header.build([[:id, type: Integer, key: true], [:name, type: String]]) }
  let(:tuple)       { Hash[id: 1, name: 'Jane', something: 'foo'] }
  let(:model)       { mock_model(:id, :name) }
  let(:object)      { model.new(id: 1, name: 'Jane') }
  let(:transformer) { fake('transformer') { Morpher::Evaluator::Transformer } }
end
