require 'spec_helper'

RSpec.describe 'Inheritance relation hierarchy' do
  before do
    ROM.setup(:memory)

    module Test
      class Users < ROM::Relation[:memory]
        dataset :users

        def by_email(email)
          restrict(email: email)
        end
      end

      class OtherUsers < Users
        register_as :other_users
      end
    end

    ROM.finalize
  end

  it 'registers parent and descendant relations' do
    rom = ROM.env

    users = rom.relations.users
    other_users = rom.relations.other_users

    expect(users).to be_instance_of(Test::Users)
    expect(other_users).to be_instance_of(Test::OtherUsers)

    jane = { name: 'Jane', email: 'jane@doe.org' }

    other_users.insert(jane)

    expect(other_users.by_email('jane@doe.org').one).to eql(jane)
  end
end
