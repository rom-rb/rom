require 'spec_helper'
require 'rom/memory'

describe 'Mappers / Renaming attributes' do
  let(:setup) { ROM.setup('memory://test') }

  before do
    setup.relation(:addresses)

    setup.relation(:users) do
      def with_address
        join(addresses)
      end

      def with_addresses
        join(addresses)
      end
    end
  end

  it 'maps renamed attributes for a base relation' do
    setup.mappers do
      define(:users) do
        model name: 'User'

        attribute :id, from: :_id
        attribute :name, from: :user_name
      end
    end

    rom = setup.finalize

    User.send(:include, Equalizer.new(:id, :name))

    rom.relations.users << { _id: 123, user_name: 'Jane' }

    jane = rom.read(:users).to_a.first

    expect(jane).to eql(User.new(id: 123, name: 'Jane'))
  end

  it 'maps renamed attributes for a wrapped relation' do
    setup.mappers do
      define(:users) do
        model name: 'User'

        attribute :id, from: :_id
        attribute :name, from: :user_name
      end

      define(:with_address, parent: :users) do
        model name: 'UserWithAddress'

        attribute :id, from: :_id
        attribute :name, from: :user_name

        wrap :address do
          attribute :id, from: :address_id
          attribute :street, from: :address_street
        end
      end
    end

    rom = setup.finalize

    UserWithAddress.send(:include, Equalizer.new(:id, :name, :address))

    rom.relations.users << { _id: 123, user_name: 'Jane' }
    rom.relations.addresses <<
      { _id: 123, address_id: 321, address_street: 'Street 1' }

    jane = rom.read(:users).with_address.first

    expect(jane).to eql(
      UserWithAddress.new(id: 123, name: 'Jane',
                          address: { id: 321, street: 'Street 1' })
    )
  end

  it 'maps renamed attributes for a grouped relation' do
    setup.mappers do
      define(:users) do
        model name: 'User'

        attribute :id, from: :_id
        attribute :name, from: :user_name
      end

      define(:with_addresses, parent: :users) do
        model name: 'UserWithAddresses'

        attribute :id, from: :_id
        attribute :name, from: :user_name

        group :addresses do
          attribute :id, from: :address_id
          attribute :street, from: :address_street
        end
      end
    end

    rom = setup.finalize

    UserWithAddresses.send(:include, Equalizer.new(:id, :name, :addresses))

    rom.relations.users << { _id: 123, user_name: 'Jane' }
    rom.relations.addresses <<
      { _id: 123, address_id: 321, address_street: 'Street 1' }
    rom.relations.addresses <<
      { _id: 123, address_id: 654, address_street: 'Street 2' }

    jane = rom.read(:users).with_addresses.first

    expect(jane).to eql(
      UserWithAddresses.new(
        id: 123,
        name: 'Jane',
        addresses: [{ id: 321, street: 'Street 1' },
                    { id: 654, street: 'Street 2' }]
      )
    )
  end
end
