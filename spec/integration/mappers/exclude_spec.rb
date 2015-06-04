require 'spec_helper'
require 'rom/memory'

describe 'Mapper definition DSL' do
  let(:setup) { ROM.setup(:memory) }
  let(:rom)   { ROM.finalize.env   }

  before do
    setup.relation(:users)

    users = setup.default.dataset(:users)

    users.insert(name: 'Joe', email: 'joe@doe.com')
    users.insert(name: 'Jane', email: 'jane@doe.com')
  end

  describe 'exclude' do
    let(:mapped_users) { rom.relation(:users).as(:users).to_a }

    it 'removes the attribute' do
      setup.mappers do
        define(:users) { exclude :email }
      end

      expect(mapped_users).to eql [{ name: 'Joe' }, { name: 'Jane' }]
    end
  end
end
