# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ROM::Relation, '.dataset' do
  include_context 'container'

  it 'injects configured dataset when block was provided' do
    configuration.relation(:users) do
      dataset do |klass|
        insert(id: 2, name: 'Joe')
        insert(id: 1, name: 'Jane')

        restrict(name: 'Jane')
      end
    end

    expect(container.relations[:users].to_a).to eql([{ id: 1, name: 'Jane' }])
  end

  it 'yields relation class for setting custom dataset proc' do
    configuration.relation(:users) do
      schema(:users) do
        attribute :id, ROM::Memory::Types::Integer.meta(primary_key: true)
        attribute :name, ROM::Memory::Types::String
      end

      dataset do |rel_klass|
        insert(id: 2, name: 'Joe')
        insert(id: 1, name: 'Jane')

        order(*rel_klass.schema.primary_key.map(&:name))
      end
    end

    expect(container.relations[:users].to_a).to eql([
      { id: 1, name: 'Jane' }, { id: 2, name: 'Joe' }
    ])
  end
end
