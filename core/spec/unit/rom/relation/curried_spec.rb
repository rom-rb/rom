require 'spec_helper'

RSpec.describe ROM::Relation::Curried do
  include_context 'gateway only'
  include_context 'users and tasks'

  let(:users_relation) do
    Class.new(ROM::Memory::Relation) do
      def by_name(name)
        restrict(name: name)
      end

      def by_names(*names)
        select { |t| names.include?(t[:name]) }
      end

      def by_name_and_age(name, age)
        restrict(name: name, age: age)
      end

      def find(criteria)
        restrict(criteria)
      end
    end.new(users_dataset)
  end

  describe '#call' do
    let(:relation) { users_relation }

    it 'materializes a relation' do
      expect(relation.by_name.('Jane').to_a).to eql([name: 'Jane', email: 'jane@doe.org'])
    end

    it 'materializes a relation view with arity -1' do
      expect(relation.by_names('Jane', 'Joe').to_a).
        to eql([{ name: 'Joe', email: 'joe@doe.org' }, { name: 'Jane', email: 'jane@doe.org' }])

      expect(relation.by_names).to eql([])
    end

    it 'returns a loaded relation' do
      expect(relation.by_name.('Jane').source).to eql(users_relation.by_name('Jane'))
    end

    it 'raises argument error if no arguments were provided' do
      expect { relation.by_name.() }.
        to raise_error(
             ArgumentError,
             "curried #{users_relation.class}#by_name relation was called without any arguments")
    end

    it 'returns self when has curried args and no additional args were provided' do
      curried = users_relation.by_name_and_age.('Jane')

      expect(curried.().__id__).to be(curried.__id__)
    end
  end

  describe '#curried?' do
    it 'returns true' do
      expect(users_relation.by_name).to be_curried
    end

    it 'returns false when relation is not curried' do
      expect(users_relation.by_name('Jane')).to_not be_curried
    end
  end

  describe '#respond_to?' do
    it 'returns true if wrapped relation responds to a method' do
      expect(users_relation.by_name).to respond_to(:dataset)
    end

    it 'returns false if wrapped relation does not respond to a method' do
      expect(users_relation.by_name).not_to respond_to(:not_here)
    end
  end

  describe '#method_missing' do
    it 'forwards to the relation' do
      expect(users_relation.by_name.dataset).to eql(users_relation.dataset)
    end

    it 'does not forward to the relation when method is auto-curried' do
      expect { users_relation.by_name.by_name }.to raise_error(NoMethodError, /by_name/)
    end

    it 'raises no method error when method is not defined' do
      expect { users_relation.by_name.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
