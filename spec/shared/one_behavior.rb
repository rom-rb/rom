# frozen_string_literal: true

shared_examples_for 'a relation that returns one tuple' do
  describe '#one' do
    it 'returns first tuple' do
      users_relation.delete(name: 'Joe', email: 'joe@doe.org')
      expect(relation.one).to eql(name: 'Jane', email: 'jane@doe.org')
    end

    it 'raises error when there is more than one tuple' do
      expect { relation.one }.to raise_error(ROM::TupleCountMismatchError)
    end
  end

  describe '#one!' do
    it 'returns first tuple' do
      users_relation.delete(name: 'Joe', email: 'joe@doe.org')
      expect(relation.one!).to eql(name: 'Jane', email: 'jane@doe.org')
    end

    it 'raises error when there is no tuples' do
      users_relation.delete(name: 'Jane', email: 'jane@doe.org')
      users_relation.delete(name: 'Joe', email: 'joe@doe.org')

      expect { relation.one! }.to raise_error(ROM::TupleCountMismatchError)
    end
  end
end
