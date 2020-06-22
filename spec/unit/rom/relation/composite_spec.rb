# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ROM::Relation::Composite do
  include_context 'gateway only'
  include_context 'users and tasks'

  let(:users_relation) do
    Class.new(ROM::Memory::Relation) do
      schema do
        attribute :name, ROM::Types::String
        attribute :email, ROM::Types::String
      end

      def by_name(name)
        restrict(name: name)
      end

      def sorted(other)
        other.source.order(:name)
      end

      def select(key)
        project(key)
      end
    end.new(users_dataset)
  end

  let(:tasks_relation) do
    Class.new(ROM::Memory::Relation) do
      def for_users(users)
        restrict(name: users.map { |u| u[:name] })
      end
    end.new(tasks_dataset)
  end

  let(:name_list) { proc { |r| r.map { |t| t[:name] } } }
  let(:upcaser) { proc { |r| r.map(&:upcase) } }

  describe '#call' do
    it 'sends a relation through mappers' do
      relation = users_relation >> name_list >> upcaser
      loaded = relation.call

      expect(loaded.source).to eql(users_relation)

      expect(loaded).to match_array(%w[JANE JOE])
    end

    it 'sends a relation through another relation' do
      relation = users_relation >> users_relation.sorted
      loaded = relation.call

      expect(loaded.source).to eql(users_relation.sorted(users_relation.call))

      expect(loaded).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end

    it 'sends a relation through another composite relation' do
      task_mapper = -> tasks_relation { tasks_relation }
      relation = users_relation.by_name('Jane') >> (tasks_relation.for_users >> task_mapper)

      loaded = relation.call

      expect(loaded.source).to eql(tasks_relation.for_users(users_relation.by_name('Jane')))

      expect(loaded).to match_array([
        { name: 'Jane', title: 'be cool', priority: 2 }
      ])
    end
  end

  describe '#each' do
    let(:relation) { users_relation >> name_list >> upcaser }

    it 'calls and iterates' do
      result = []
      relation.each do |object|
        result << object
      end
      expect(result).to match_array(%w[JANE JOE])
    end

    it 'returns enumerator if block is not provided' do
      expect(relation.each.to_a).to match_array(%w[JANE JOE])
    end
  end

  describe '#first' do
    let(:relation) { users_relation >> name_list >> upcaser }

    it 'calls and returns the first object' do
      expect(relation.first).to eql('JOE')
    end
  end

  describe '#__send__' do
    it 'proxies Kernel methods' do
      relation = (users_relation >> name_list >> upcaser).__send__(:select, :name)

      expect(relation.call).to match_array(%w[JANE JOE])
    end
  end
end
