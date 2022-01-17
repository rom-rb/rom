# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Mappers / Renaming attributes" do
  include_context "container"

  before do
    configuration.relation(:addresses)

    configuration.relation(:users) do
      def with_address
        join(addresses)
      end

      def with_addresses
        join(addresses)
      end
    end
  end

  it "maps renamed attributes for a base relation" do
    configuration.mappers do
      define(:users) do
        model name: "Test::User"

        attribute :id, from: :_id
        attribute :name, from: :user_name
      end
    end

    container.mappers[:users][:users]

    Test::User.send(:include, Dry::Equalizer(:id, :name))

    container.relations[:users] << {_id: 123, user_name: "Jane"}

    jane = container.relations[:users].map_with(:users).first

    expect(jane).to eql(Test::User.new(id: 123, name: "Jane"))
  end

  it "maps renamed attributes for a wrapped relation" do
    configuration.mappers do
      define(:users) do
        model name: "Test::User"

        attribute :id, from: :_id
        attribute :name, from: :user_name
      end

      define(:with_address, parent: :users) do
        model name: "Test::UserWithAddress"

        attribute :id, from: :_id
        attribute :name, from: :user_name

        wrap :address do
          attribute :id, from: :address_id
          attribute :street, from: :address_street
        end
      end
    end

    container.mappers[:users][:users]
    container.mappers[:users][:with_address]

    Test::UserWithAddress.send(:include, Dry::Equalizer(:id, :name, :address))

    container.relations[:users] << {_id: 123, user_name: "Jane"}

    container.relations[:addresses] <<
      {_id: 123, address_id: 321, address_street: "Street 1"}

    jane = container.relations[:users].with_address.map_with(:with_address).first

    expect(jane).to eql(
      Test::UserWithAddress.new(id: 123, name: "Jane",
                                address: {id: 321, street: "Street 1"})
    )
  end

  it "maps renamed attributes for a grouped relation" do
    configuration.mappers do
      define(:users) do
        model name: "Test::User"

        attribute :id, from: :_id
        attribute :name, from: :user_name
      end

      define(:with_addresses, parent: :users) do
        model name: "Test::UserWithAddresses"

        attribute :id, from: :_id
        attribute :name, from: :user_name

        group :addresses do
          attribute :id, from: :address_id
          attribute :street, from: :address_street
        end
      end
    end

    container.mappers[:users][:users]
    container.mappers[:users][:with_addresses]

    Test::UserWithAddresses.send(:include, Dry::Equalizer(:id, :name, :addresses))

    container.relations[:users] << {_id: 123, user_name: "Jane"}

    container.relations[:addresses] <<
      {_id: 123, address_id: 321, address_street: "Street 1"}
    container.relations[:addresses] <<
      {_id: 123, address_id: 654, address_street: "Street 2"}

    jane = container.relations[:users].with_addresses.map_with(:with_addresses).first

    expect(jane).to eql(
      Test::UserWithAddresses.new(
        id: 123,
        name: "Jane",
        addresses: [{id: 321, street: "Street 1"},
                    {id: 654, street: "Street 2"}]
      )
    )
  end
end
