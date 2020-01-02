# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Registering Custom Mappers' do
  include_context 'container'
  include_context 'users and tasks'

  it 'allows registering arbitrary objects as mappers' do
    model = Struct.new(:name, :email)

    mapper = -> users {
      users.map { |tuple| model.new(*tuple.values_at(:name, :email)) }
    }

    configuration.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end

    configuration.mappers do
      register(:users, entity: mapper)
    end

    users = container.relations[:users].by_name('Jane').map_with(:entity)

    expect(users).to match_array([model.new('Jane', 'jane@doe.org')])
  end
end
