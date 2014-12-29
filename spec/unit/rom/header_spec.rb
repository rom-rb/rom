require 'spec_helper'

describe ROM::Header do
  describe '.coerce' do
    subject(:header) { ROM::Header.coerce(input) }

    context 'with a primitive type' do
      let(:input) { [[:name, type: :string]] }

      let(:expected) do
        ROM::Header.new(name: ROM::Header::Attribute.coerce(input.first))
      end

      it 'returns a header with coerced attributes' do
        expect(header).to eql(expected)

        expect(header[:name].type).to be(:string)
      end
    end

    context 'with a collection type' do
      let(:input) { [[:tasks, header: [[:title]], type: :array, model: model]] }
      let(:model) { Class.new }

      let(:expected) do
        ROM::Header.new(tasks: ROM::Header::Attribute.coerce(input.first))
      end

      it 'returns a header with coerced attributes' do
        expect(header).to eql(expected)

        tasks = header[:tasks]

        expect(tasks.type).to be(:array)
        expect(tasks.header.model).to be(model)
        expect(tasks.header).to eql(ROM::Header.coerce([[:title]], model))

        expect(input.first[1])
          .to eql(header: [[:title]], type: :array, model: model)
      end
    end

    context 'with a hash type' do
      let(:input) { [[:task, header: [[:title]], type: :hash, model: model]] }
      let(:model) { Class.new }

      let(:expected) do
        ROM::Header.new(task: ROM::Header::Attribute.coerce(input.first))
      end

      it 'returns a header with coerced attributes' do
        expect(header).to eql(expected)

        tasks = header[:task]

        expect(tasks.type).to be(:hash)
        expect(tasks.header.model).to be(model)
        expect(tasks.header).to eql(ROM::Header.coerce([[:title]], model))

        expect(input.first[1])
          .to eql(header: [[:title]], type: :hash, model: model)
      end
    end
  end
end
