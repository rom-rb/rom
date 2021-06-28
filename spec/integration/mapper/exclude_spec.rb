# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Mapper definition DSL" do
  include_context "container"

  before do
    configuration.relation(:users)

    users = configuration.gateways[:default].dataset(:users)

    users.insert(name: "Joe", email: "joe@doe.com")
    users.insert(name: "Jane", email: "jane@doe.com")
  end

  describe "exclude" do
    let(:mapped_users) { container.relations[:users].map_with(:users).to_a }

    it "removes the attribute" do
      configuration.mappers do
        define(:users) { exclude :email }
      end

      expect(mapped_users).to eql [{name: "Joe"}, {name: "Jane"}]
    end
  end
end
