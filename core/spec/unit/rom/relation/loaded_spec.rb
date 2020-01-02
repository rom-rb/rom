# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ROM::Relation::Loaded do
  include_context 'no container'
  include_context 'users and tasks'

  subject(:users) { ROM::Relation::Loaded.new(users_relation) }

  describe '#each' do
    it 'yields tuples from relation' do
      result = []

      users.each do |tuple|
        result << tuple
      end

      expect(result).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end

    it 'returns enumerator when block is not provided' do
      expect(users.each.to_a).to eql(users.collection.to_a)
    end
  end

  describe '#to_ary' do
    it 'coerces to an array' do
      expect(users.to_ary).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end
  end

  describe '#pluck' do
    it 'returns a list of values under provided key' do
      expect(users.pluck(:email)).to eql(%w[joe@doe.org jane@doe.org])
    end
  end

  describe '#primary_keys' do
    it 'returns a list of primary key values' do
      expect(users.source).to receive(:primary_key).and_return(:name)
      expect(users.primary_keys).to eql(%w[Joe Jane])
    end
  end

  it_behaves_like 'a relation that returns one tuple' do
    let(:relation) { users }
  end
end
