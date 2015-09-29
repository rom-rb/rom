require 'spec_helper'
require 'rom/memory'

describe 'Mapper definition DSL' do
  let(:setup) { ROM.setup(:memory) }
  let(:rom)   { ROM.finalize.env   }

  before do
    setup.relation(:users)

    users = setup.default.dataset(:users)
    users.insert(
      user_id: 1,
      user_name: 'Joe',
      user_email: 'joe@doe.com',
      'user.skype' => 'joe',
      :'user.phone' => '1234567890'
    )
  end

  describe 'prefix' do
    subject(:mapped_users) { rom.relation(:users).as(:users).to_a }

    it 'applies new separator to the attributes following it' do
      setup.mappers do
        define(:users) do
          prefix :user
          attribute :id
          attribute :name
          wrap :contacts do
            attribute :email

            prefix_separator '.'
            attribute 'skype'
            attribute :phone
          end
        end
      end

      expect(mapped_users).to eql [
        {
          id: 1,
          name: 'Joe',
          contacts: {
            email: 'joe@doe.com',
            'skype' => 'joe',
            phone: '1234567890'
          }
        }
      ]
    end
  end
end
