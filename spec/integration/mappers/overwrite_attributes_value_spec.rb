require 'spec_helper'
require 'rom/memory'

describe 'Mappers / Attributes value' do
  let(:setup) { ROM.setup(:memory) }

  before do
    setup.relation(:users)
  end

  it 'allows to manipulate attribute value' do
    class Test::UserMapper < ROM::Mapper
      relation :users

      attribute :id
      attribute :name, from: :first_name do
        'John'
      end
      attribute :age do
        9+9
      end
      attribute :weight do |t|
        t+15
      end
    end

    rom = setup.finalize

    rom.relations.users << {
      id: 123,
      first_name: 'Jane',
      weight: 75
    }

    jane = rom.relation(:users).as(:users).first

    expect(jane).to eql(id: 123, name: 'John', weight: 90, age: 18)
  end

  it 'raise ArgumentError if type and block used at the same time' do
    expect {
      class Test::UserMapper < ROM::Mapper
        relation :users

        attribute :name, type: :string do
          'John'
        end
      end
    }.to raise_error(ArgumentError, "can't specify type and block at the same time")
  end
end
