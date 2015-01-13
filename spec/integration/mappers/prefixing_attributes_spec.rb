require 'spec_helper'

describe 'Mappers / Prefixing attributes' do
  let(:setup) { ROM.setup('memory://test') }

  before do
    setup.relation(:users)
  end

  it 'automatically maps all attributes using the provided prefix' do
    setup.mappers do
      define(:users, prefix: :user) do
        model name: 'User'

        attribute :id
        attribute :name
        attribute :email
      end
    end

    rom = setup.finalize

    User.send(:include, Equalizer.new(:id, :name, :email))

    rom.relations.users << {
      user_id: 123,
      user_name: 'Jane',
      user_email: 'jane@doe.org'
    }

    jane = rom.read(:users).to_a.first

    expect(jane).to eql(User.new(id: 123, name: 'Jane', email: 'jane@doe.org'))
  end
end
