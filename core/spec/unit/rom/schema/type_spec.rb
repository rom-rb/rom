require 'rom/attribute'

RSpec.describe ROM::Attribute do
  describe '#inspect' do
    context 'with a primitive definition' do
      subject(:type) do
        ROM::Attribute.new(ROM::Types::Integer).meta(name: :id, primary_key: true)
      end

      specify do
        expect(type.inspect).to eql("#<ROM::Attribute[Integer] name=:id primary_key=true alias=nil>")
      end
    end

    context 'with a sum' do
      subject(:type) do
        ROM::Attribute.new(ROM::Types::Bool).meta(name: :admin)
      end

      specify do
        expect(type.inspect).to eql("#<ROM::Attribute[TrueClass | FalseClass] name=:admin alias=nil>")
      end
    end

    context 'with an option' do
      subject(:type) do
        ROM::Attribute.new(ROM::Types::Bool, alias: :adm).meta(name: :admin)
      end

      specify do
        expect(type.inspect).to eql("#<ROM::Attribute[TrueClass | FalseClass] name=:admin alias=:adm>")
      end
    end
  end

  describe '#aliased' do
    subject(:type) do
      ROM::Attribute.new(ROM::Types::String).meta(name: :user_name)
    end

    specify do
      expect(type.as(:name).alias).to eql(:name)
    end
  end

  describe '#method_missing' do
    subject(:type) do
      ROM::Attribute.new(ROM::Types::Integer).meta(name: :id, primary_key: true)
    end

    specify do
      expect(type.meta).to eql(name: :id, primary_key: true)
    end

    specify do
      expect { type.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
