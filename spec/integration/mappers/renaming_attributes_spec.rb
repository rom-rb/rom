require 'spec_helper'

describe 'Renaming attributes' do
  it 'maps renamed attributes' do
    rom = ROM.setup(memory: 'memory://test')

    rom.schema do
      base_relation(:users) do
        repository :memory

        attribute :_id
        attribute :user_name
      end
    end

    rom.relations do
      register(:users)
    end

    rom.mappers do
      define(:users) do
        model name: 'User'

        attribute :id, from: :_id
        attribute :name, from: :user_name
      end
    end

    User.send(:include, Equalizer.new(:id, :name))

    rom.schema.users << { _id: 123, user_name: 'Jane' }

    jane = rom.read(:users).to_a.first

    expect(jane).to eql(User.new(id: 123, name: 'Jane'))
  end
end
