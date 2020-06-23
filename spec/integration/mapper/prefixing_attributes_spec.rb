# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Mappers / Prefixing attributes" do
  include_context "container"

  before do
    configuration.relation(:users)
  end

  it "automatically maps all attributes using the provided prefix" do
    class Test::UserMapper < ROM::Mapper
      relation :users
      prefix :user

      model name: "Test::User"

      attribute :id
      attribute :name
      attribute :email
    end

    configuration.register_mapper(Test::UserMapper)

    container.relations.users << {
      user_id: 123,
      user_name: "Jane",
      user_email: "jane@doe.org"
    }

    Test::User.send(:include, Dry::Equalizer(:id, :name, :email))

    jane = container.relations[:users].map_with(:users).first

    expect(jane).to eql(Test::User.new(id: 123, name: "Jane", email: "jane@doe.org"))
  end
end
