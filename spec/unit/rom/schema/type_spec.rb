require 'rom/schema/type'

RSpec.describe ROM::Schema::Type do
  describe '#inspect' do
    subject(:type) do
      ROM::Schema::Type.new(ROM::Types::Int).meta(name: :id, primary_key: true)
    end

    specify do
      expect(type.inspect).to eql("#<ROM::Schema::Type[Integer] name=:id primary_key=true>")
    end
  end
end
