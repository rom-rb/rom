require 'spec_helper'

describe ROM::Relation::Lazy do
  include_context 'users and tasks'

  let(:users) { rom.relations.users.to_lazy }
  let(:tasks) { rom.relations.tasks.to_lazy }

  before do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end

      def by_email(email)
        restrict(name: email)
      end

      def by_name_and_email(name, email)
        by_name(name).by_email(email)
      end

      def all(*args)
        if args.any?
          restrict(*args)
        else
          self
        end
      end
    end

    setup.relation(:tasks) do
      def for_users(users)
        names = users.map { |u| u[:name] }
        restrict { |t| names.include?(t[:name]) }
      end
    end
  end

  describe '#method_missing' do
    it 'forwards to relation and auto-curries' do
      relation = users.by_name_and_email('Jane')

      expect(relation.name).to eql(:by_name_and_email)
      expect(relation.curry_args).to eql(['Jane'])

      expect(relation['jane@doe.org']).to match_array(
        rom.relations.users.by_name_and_email('Jane', 'jane@doe.org')
      )
    end

    it 'forwards to relation and return lazy when arity is unknown' do
      relation = users.all
      expect(relation.name).to eql(:all)
      expect(relation).to match_array(rom.relations.users.all)
    end

    it 'raises NoMethodError when relation does not respond to a method' do
      expect { users.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end

  describe '#call' do
    it 'auto-curries' do
      relation = users.by_name

      expect(relation.name).to eql(:by_name)
      expect(relation['Jane'].to_a).to eql(rom.relations.users.by_name('Jane').to_a)
    end

    it 'returns relation' do
      expect(users.call.to_a).to eql(rom.relations.users.to_a)
    end

    describe 'using mappers' do
      subject(:users) { rom.relations.users.to_lazy(mappers: mappers) }

      let(:name_list) { proc { |r| r.map { |t| t[:name] } } }
      let(:upcaser) { proc { |r| r.map(&:upcase) } }
      let(:mappers) { { name_list: name_list, upcaser: upcaser } }

      it 'sends relation through mappers' do
        relation = users.map_with(:name_list, :upcaser).by_name('Jane')

        expect(relation.call.to_a).to eql(['JANE'])
      end
    end
  end

  describe '#>>' do
    it 'composes two relations' do
      other = users.by_name('Jane') >> tasks.for_users

      expect(other.to_a).to eql([
        [{ name: 'Jane', email: 'jane@doe.org' }],
        [{ name: 'Jane', title: 'be cool', priority: 2 }]
      ])
    end
  end
end
