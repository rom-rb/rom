# frozen_string_literal: true

RSpec.describe ROM::Relation::Combined do
  subject(:relation) do
    ROM::Relation::Combined.new(users, [])
  end

  let(:users) do
    Class.new(ROM::Relation) do
      def by_name(_name)
        self
      end
    end.new([])
  end

  describe '#method_missing' do
    it 'responds to the root methods' do
      expect(relation).to respond_to(:by_name)
    end

    it 'forwards methods to the root and decorates response' do
      expect(relation.by_name('Jane')).to be_instance_of(ROM::Relation::Combined)
    end

    it 'forwards methods to the root and decorates curried response' do
      expect(relation.by_name).to be_instance_of(ROM::Relation::Combined)
    end

    it 'returns original response from the root' do
      expect(relation.name).to be(users.name)
    end

    it 'raises no method error' do
      expect { relation.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
