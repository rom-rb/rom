# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mapper definition DSL' do
  include_context 'container'

  before do
    configuration.relation(:users)

    users = configuration.default.dataset(:users)
    users.insert(
      user_id: 1,
      user_name: 'Joe',
      user_email: 'joe@doe.com',
      'user.skype' => 'joe',
      :'user.phone' => '1234567890'
    )
  end

  describe 'prefix' do
    subject(:mapped_users) { container.relations[:users].map_with(:users).to_a }

    it 'applies new separator to the attributes following it' do
      configuration.mappers do
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
