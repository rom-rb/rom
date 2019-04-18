require 'rom/attribute'

RSpec.describe ROM::Attribute do
  describe '#inspect' do
    context 'with a primitive definition' do
      subject(:attr) do
        ROM::Attribute.new(ROM::Types::Integer, name: :id).meta(primary_key: true)
      end

      specify do
        expect(attr.inspect).to eql("#<ROM::Attribute[Integer] name=:id primary_key=true alias=nil>")
      end
    end

    context 'with a sum' do
      subject(:attr) do
        ROM::Attribute.new(ROM::Types::Bool, name: :admin)
      end

      specify do
        expect(attr.inspect).to eql("#<ROM::Attribute[TrueClass | FalseClass] name=:admin alias=nil>")
      end
    end

    context 'with an option' do
      subject(:attr) do
        ROM::Attribute.new(ROM::Types::Bool, name: :admin, alias: :adm)
      end

      specify do
        expect(attr.inspect).to eql("#<ROM::Attribute[TrueClass | FalseClass] name=:admin alias=:adm>")
      end
    end
  end

  describe '#aliased' do
    subject(:attr) do
      ROM::Attribute.new(ROM::Types::String, name: :user_name)
    end

    specify do
      expect(attr.as(:name).alias).to eql(:name)
    end
  end

  describe '#method_missing' do
    subject(:attr) do
      ROM::Attribute.new(ROM::Types::Integer, name: :id).meta(primary_key: true)
    end

    specify do
      expect(attr.meta).to eql(primary_key: true)
    end

    specify do
      expect { attr.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
