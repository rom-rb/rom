require 'rom/schema/attribute'

RSpec.describe ROM::Schema::Attribute do
  describe '#inspect' do
    context 'with a primitive definition' do
      subject(:type) do
        ROM::Schema::Attribute.new(ROM::Types::Int).meta(name: :id, primary_key: true)
      end

      specify do
        expect(type.inspect).to eql("#<ROM::Schema::Attribute[Integer] name=:id primary_key=true>")
      end
    end

    context 'with a sum' do
      subject(:type) do
        ROM::Schema::Attribute.new(ROM::Types::Bool).meta(name: :admin)
      end

      specify do
        expect(type.inspect).to eql("#<ROM::Schema::Attribute[TrueClass | FalseClass] name=:admin>")
      end
    end
  end

  describe '#aliased' do
    subject(:type) do
      ROM::Schema::Attribute.new(ROM::Types::String).meta(name: :user_name)
    end

    specify do
      expect(type.as(:name).meta[:alias]).to eql(:name)
    end
  end

  describe '#method_missing' do
    subject(:type) do
      ROM::Schema::Attribute.new(ROM::Types::Int).meta(name: :id, primary_key: true)
    end

    specify do
      expect(type.meta).to eql(name: :id, primary_key: true)
    end

    specify do
      expect { type.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
