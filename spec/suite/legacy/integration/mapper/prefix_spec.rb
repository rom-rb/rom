# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Mapper definition DSL" do
  include_context "container"

  describe "prefix" do
    it "applies new prefix to the attributes following it" do
      configuration.relation(:users)

      configuration.mappers do
        define(:users) do
          prefix :user
          attribute :id
          attribute :name
          wrap :contacts do
            attribute :email

            prefix :contact
            attribute :skype
            attribute :phone
          end
        end
      end

      users_relation.insert(
        user_id: 1,
        user_name: "Joe",
        user_email: "joe@doe.com",
        contact_skype: "joe",
        contact_phone: "1234567890"
      )

      mapped_users = users_relation.map_with(:users).to_a

      expect(mapped_users).to eql [
        {
          id: 1,
          name: "Joe",
          contacts: {email: "joe@doe.com", skype: "joe", phone: "1234567890"}
        }
      ]
    end
  end
end
