require 'spec_helper'
require 'rom/memory'

RSpec.describe 'Inline setup' do
  before do
    module Test
      module Dummy
        class Gateway < ROM::Memory::Gateway
          def schema
            [:users, :tasks]
          end
        end

        class Relation < ROM::Relation
          adapter :dummy
        end
      end
    end

    ROM.register_adapter :dummy, Test::Dummy
  end

  context 'using global env' do
    it 'auto-registers components' do
      rom = ROM.setup(:dummy) do
        relation(:users)
      end

      users = rom.relation(:users)

      expect(users).to be_kind_of(Test::Dummy::Relation)
    end
  end

  context 'using local env' do
    it 'auto-registers components' do
      env = ROM::Environment.new

      rom = env.setup(:dummy) do
        relation(:users)
      end

      users = rom.relation(:users)

      expect(users).to be_kind_of(Test::Dummy::Relation)
    end
  end

  context 'defining a relation with custom dataset name' do
    it 'registers under provided name and uses custom dataset' do
      env = ROM::Environment.new

      rom = env.setup(:dummy) do
        relation(:super_users) do
          dataset :users
        end
      end

      users = rom.relation(:super_users)

      expect(users).to be_kind_of(Test::Dummy::Relation)
      expect(users.dataset).to be(rom.gateways[:default].dataset(:users))
    end
  end
end
