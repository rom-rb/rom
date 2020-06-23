# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Mappers / embedded" do
  include_context "container"

  before do
    configuration.relation(:users)
  end

  it "allows mapping embedded tuples" do
    configuration.mappers do
      define(:users) do
        model name: "Test::User"

        attribute :name, from: "name"

        embedded :tasks, from: "tasks" do
          attribute :title, from: "title"
        end
      end
    end

    container.relations.users << {
      "name" => "Jane",
      "tasks" => [{"title" => "Task One"}, {"title" => "Task Two"}]
    }

    jane = container.relations[:users].map_with(:users).first

    expect(jane.name).to eql("Jane")
    expect(jane.tasks).to eql([{title: "Task One"}, {title: "Task Two"}])
  end

  it "allows mapping embedded tuple" do
    configuration.mappers do
      define(:users) do
        model name: "Test::User"

        attribute :name, from: "name"

        embedded :address, from: "address", type: :hash do
          model name: "Test::Address"
          attribute :street, from: "street"
          attribute :city, from: "city"
        end
      end
    end

    container.relations.users << {
      "name" => "Jane",
      "address" => {"street" => "Somewhere 1", "city" => "NYC"}
    }

    jane = container.relations[:users].map_with(:users).first

    Test::Address.send(:include, Dry::Equalizer(:street, :city))

    expect(jane.name).to eql("Jane")
    expect(jane.address).to eql(Test::Address.new(street: "Somewhere 1", city: "NYC"))
  end
end
