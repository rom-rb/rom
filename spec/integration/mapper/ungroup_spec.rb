# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Mapper definition DSL" do
  include_context "container"

  before do
    configuration.relation(:users)

    users = container.gateways[:default].dataset(:users)
    users.insert(name: "Joe", emails: [
      {address: "joe@home.org", type: "home"},
      {address: "joe@job.com",  type: "job"},
      {address: "joe@doe.com",  type: "job"},
      {address: "joe@thor.org"},
      {type: "home"},
      {}
    ])
    users.insert(name: "Jane", emails: [])
  end

  describe "ungroup" do
    subject(:mapped_users) { container.relations[:users].map_with(:users).to_a }

    it "partially ungroups attributes" do
      configuration.mappers do
        define(:users) { ungroup emails: [:type] }
      end

      expect(mapped_users).to eql [
        {
          name: "Joe", type: "home",
          emails: [{address: "joe@home.org"}, {address: nil}]
        },
        {
          name: "Joe", type: "job",
          emails: [{address: "joe@job.com"}, {address: "joe@doe.com"}]
        },
        {
          name: "Joe", type: nil,
          emails: [{address: "joe@thor.org"}, {address: nil}]
        },
        {name: "Jane"}
      ]
    end

    it "removes group when all attributes extracted" do
      configuration.mappers do
        define(:users) { ungroup emails: %i[address type foo] }
      end

      expect(mapped_users).to eql [
        {name: "Joe",  address: "joe@home.org", type: "home"},
        {name: "Joe",  address: "joe@job.com",  type: "job"},
        {name: "Joe",  address: "joe@doe.com",  type: "job"},
        {name: "Joe",  address: "joe@thor.org", type: nil},
        {name: "Joe",  address: nil,            type: "home"},
        {name: "Joe",  address: nil,            type: nil},
        {name: "Jane"}
      ]
    end

    it "accepts block syntax" do
      configuration.mappers do
        define(:users) do
          ungroup :emails do
            attribute :address
            attribute :type
          end
        end
      end

      expect(mapped_users).to eql [
        {name: "Joe",  address: "joe@home.org", type: "home"},
        {name: "Joe",  address: "joe@job.com",  type: "job"},
        {name: "Joe",  address: "joe@doe.com",  type: "job"},
        {name: "Joe",  address: "joe@thor.org", type: nil},
        {name: "Joe",  address: nil,            type: "home"},
        {name: "Joe",  address: nil,            type: nil},
        {name: "Jane"}
      ]
    end

    it "renames ungrouped attributes" do
      configuration.mappers do
        define(:users) do
          ungroup :emails do
            attribute :email, from: :address
            attribute :type
          end
        end
      end

      expect(mapped_users).to eql [
        {name: "Joe",  email: "joe@home.org", type: "home"},
        {name: "Joe",  email: "joe@job.com",  type: "job"},
        {name: "Joe",  email: "joe@doe.com",  type: "job"},
        {name: "Joe",  email: "joe@thor.org", type: nil},
        {name: "Joe",  email: nil,            type: "home"},
        {name: "Joe",  email: nil,            type: nil},
        {name: "Jane"}
      ]
    end

    it "skips existing attributes" do
      configuration.mappers do
        define(:users) do
          ungroup :emails do
            attribute :name, from: :address
            attribute :type
          end
        end
      end

      expect(mapped_users).to eql [
        {name: "Joe",  type: "home"},
        {name: "Joe",  type: "job"},
        {name: "Joe",  type: "job"},
        {name: "Joe",  type: nil},
        {name: "Joe",  type: "home"},
        {name: "Joe",  type: nil},
        {name: "Jane"}
      ]
    end
  end
end
