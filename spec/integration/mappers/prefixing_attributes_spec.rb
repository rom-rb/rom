require 'spec_helper'
require 'rom/memory'

describe 'Mappers / Prefixing attributes' do
  let(:setup) { ROM.setup(:memory) }

  before do
    setup.relation(:users)
  end

  it 'automatically maps all attributes using the provided prefix' do
    class ROMSpec::UserMapper < ROM::Mapper
      relation :users
      prefix :user

      model name: 'ROMSpec::User'

      attribute :id
      attribute :name
      attribute :email
    end

    rom = setup.finalize

    ROMSpec::User.send(:include, Equalizer.new(:id, :name, :email))

    rom.relations.users << {
      user_id: 123,
      user_name: 'Jane',
      user_email: 'jane@doe.org'
    }

    jane = rom.read(:users).to_a.first

    expect(jane).to eql(ROMSpec::User.new(id: 123, name: 'Jane', email: 'jane@doe.org'))
  end
end
