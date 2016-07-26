RSpec.describe ROM::Struct do
  subject(:struct) do
    Class.new(ROM::Struct) do
      attr_reader :id, :name

      def initialize(id, name)
        @id, @name = id, name
      end

      def id
        @id.to_i
      end
    end.new("1", "Jane")
  end

  describe '#[]' do
    it 'reads an attribute value' do
      expect(struct.id).to be(1)
      expect(struct.name).to eql("Jane")
    end
  end
end
