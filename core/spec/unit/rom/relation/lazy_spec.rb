require 'spec_helper'

RSpec.describe ROM::Relation do
  include_context 'gateway only'
  include_context 'users and tasks'

  let(:users_relation) do
    Class.new(ROM::Memory::Relation) do
      def by_name(name)
        restrict(name: name)
      end

      def by_name_sorted(name, order_by = :name)
        by_name(name).order(order_by)
      end

      def by_email(email)
        restrict(name: email)
      end

      def by_name_and_email(name, email)
        by_name(name).by_email(email)
      end

      def by_name_and_email_sorted(name, email, order_by)
        by_name_and_email(name, email).order(order_by)
      end

      def all(*args)
        if args.any?
          restrict(*args)
        else
          self
        end
      end
    end.new(users_dataset)
  end

  let(:tasks_relation) do
    Class.new(ROM::Memory::Relation) do
      def for_users(users)
        names = users.map { |u| u[:name] }
        restrict { |t| names.include?(t[:name]) }
      end
    end.new(tasks_dataset)
  end

  it_behaves_like 'a relation that returns one tuple' do
    let(:relation) { users_relation }
  end

  describe '#map_with' do
    it 'raises error when unknown mapper was selected' do
      expect {
        users_relation.map_with(:not_here)
      }.to raise_error(ROM::MapperMissingError, /not_here/)
    end
  end

  describe '#method_missing' do
    it 'forwards to relation and auto-curries' do
      relation = users_relation.by_name_and_email_sorted('Jane')

      expect(relation.view).to be(:by_name_and_email_sorted)
      expect(relation.curry_args).to eql(['Jane'])

      relation = relation['jane@doe.org']

      expect(relation.view).to be(:by_name_and_email_sorted)
      expect(relation.curry_args).to eql(['Jane', 'jane@doe.org'])

      expect(relation[:email]).to match_array(
        users_relation.by_name_and_email_sorted('Jane', 'jane@doe.org', :email)
      )
    end

    it 'forwards to relation and does not auto-curry when it is not needed' do
      relation = users_relation.by_name('Jane')

      expect(relation).to_not be_curried
      expect(relation).to match_array(users_relation.by_name('Jane'))
    end

    it 'forwards to relation and return lazy when arity is unknown' do
      relation = users_relation.all(name: 'Jane')
      expect(relation).to_not be_curried
      expect(relation).to match_array(users_relation.by_name('Jane').to_a)
    end

    it 'returns original response if it is not a relation' do
      expect(users_relation.gateway).to be(:default)
    end

    it 'raises NoMethodError when relation does not respond to a method' do
      expect { users_relation.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end

  describe '#call' do
    it 'auto-curries' do
      relation = users_relation.by_name

      expect(relation.view).to eql(:by_name)
      expect(relation['Jane'].to_a).to eql(users_relation.by_name('Jane').to_a)
    end

    it 'returns relation' do
      expect(users_relation.call.to_a).to eql(users_relation.to_a)
    end

    describe 'using mappers' do
      subject(:users) { users_relation.with(mappers: ROM::MapperRegistry.build(mappers)) }

      let(:name_list) { proc { |r| r.map { |t| t[:name] } } }
      let(:upcaser) { proc { |r| r.map(&:upcase) } }
      let(:mappers) { { name_list: name_list, upcaser: upcaser } }

      it 'sends relation through mappers' do
        relation = users.map_with(:name_list, :upcaser).by_name('Jane')

        expect(relation.call.to_a).to eql(['JANE'])
      end
    end
  end

  describe '#first' do
    it 'return first tuple' do
      expect(users_relation.first).to eql(name: 'Joe', email: 'joe@doe.org')
    end

    it 'raises when relation is curried and arity does not match' do
      expect { users_relation.by_name.first }.to raise_error(
        ArgumentError, "#{users_relation.class.to_s}#by_name arity is 1 (0 args given)"
      )
    end

    it 'does not raise when relation is curried and arity matches' do
      expect { users_relation.by_name_sorted('Joe').first }.to_not raise_error
    end
  end

  describe '#each' do
    it 'yields relation tuples' do
      result = []
      users_relation.each do |tuple|
        result << tuple
      end
      expect(result).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end

    it 'returns an enumerator if block is not provided' do
      expect(users_relation.each.to_a).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end

    it 'raises when relation is curried and arity does not match' do
      expect { users_relation.by_name.each {} }.to raise_error(
        ArgumentError, "#{users_relation.class.to_s}#by_name arity is 1 (0 args given)"
      )
    end

    it 'does not raise when relation is curried and arity matches' do
      expect { users_relation.by_name_sorted('Jane').first }.to_not raise_error
    end
  end

  describe '#to_ary' do
    it 'returns an array with relation tuples' do
      expect(users_relation.to_ary).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end

    it 'raises when relation is curried and arity does not match' do
      expect { users_relation.by_name.to_ary }.to raise_error(
        ArgumentError, "#{users_relation.class.to_s}#by_name arity is 1 (0 args given)"
      )
    end

    it 'does not raise when relation is curried and arity matches' do
      expect { users_relation.by_name_sorted('Jane').first }.to_not raise_error
    end
  end

  describe '#>>' do
    it 'composes two relations' do
      other = users_relation.by_name('Jane') >> tasks_relation.for_users

      expect(other).to match_array([
        { name: 'Jane', title: 'be cool', priority: 2 }
      ])
    end

    it_behaves_like 'a relation that returns one tuple' do
      let(:relation) { users_relation >> proc { |r| r } }

      describe 'using a mapper' do
        it 'returns one mapped tuple' do
          mapper = proc { |r| r.map { |t| t[:name].upcase } }
          relation = users_relation.by_name('Jane') >> mapper

          expect(relation.one).to eql('JANE')
          expect(relation.one!).to eql('JANE')
        end
      end
    end
  end
end
