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
end
