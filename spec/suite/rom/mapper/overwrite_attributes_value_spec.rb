# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Mappers / Attributes value" do
  include_context "container"

  before do
    configuration.relation(:users)
  end

  it "allows to manipulate attribute value" do
    class Test::UserMapper < ROM::Mapper
      config.component.id = :users
      config.component.namespace = :users

      attribute :id

      attribute :name, from: :first_name do
        "John"
      end

      attribute :age do
        9 + 9
      end

      attribute :weight do |t|
        t + 15
      end
    end

    configuration.register_mapper(Test::UserMapper)

    container.relations[:users] << {
      id: 123,
      first_name: "Jane",
      weight: 75
    }

    jane = container.relations[:users].map_with(:users).first

    expect(jane).to eql(id: 123, name: "John", weight: 90, age: 18)
  end

  it "raise ArgumentError if type and block used at the same time" do
    expect {
      class Test::UserMapper < ROM::Mapper
        config.component.id = :users
        config.component.namespace = :users

        attribute :name, type: :string do
          "John"
        end
      end
    }.to raise_error(ArgumentError, "can't specify type and block at the same time")
  end
end
