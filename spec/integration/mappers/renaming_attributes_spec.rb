require 'spec_helper'

describe 'Mappers / Renaming attributes' do
  let(:setup) { ROM.setup(memory: 'memory://test') }

  before do
    setup.schema do
      base_relation(:users) do
        repository :memory

        attribute :_id
        attribute :user_name
      end

      base_relation(:addresses) do
        repository :memory

        attribute :address_id
        attribute :address_street
      end
    end

    setup.relation(:addresses)

    setup.relation(:users) do
      include ROM::RA

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

    rom.schema.users << { _id: 123, user_name: 'Jane' }

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

    rom.schema.users << { _id: 123, user_name: 'Jane' }
    rom.schema.addresses << { _id: 123, address_id: 321,
                              address_street: 'Street 1' }

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

    rom.schema.users << { _id: 123, user_name: 'Jane' }
    rom.schema.addresses << { _id: 123, address_id: 321,
                              address_street: 'Street 1' }
    rom.schema.addresses << { _id: 123, address_id: 654,
                              address_street: 'Street 2' }

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
