require 'spec_helper'
require 'rom/memory'

describe 'Mappers / Prefixing attributes' do
  let(:setup) { ROM.setup(:memory) }

  before do
    setup.relation(:users)
  end

  it 'automatically maps all attributes using the provided prefix' do
    class Test::UserMapper < ROM::Mapper
      relation :users
      prefix :user

      model name: 'Test::User'

      attribute :id
      attribute :name
      attribute :email
    end

    rom = setup.finalize

    Test::User.send(:include, Equalizer.new(:id, :name, :email))

    rom.relations.users << {
      user_id: 123,
      user_name: 'Jane',
      user_email: 'jane@doe.org'
    }

    jane = rom.relation(:users).as(:users).first

    expect(jane).to eql(Test::User.new(id: 123, name: 'Jane', email: 'jane@doe.org'))
  end
end
