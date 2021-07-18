# frozen_string_literal: true

require "rom/relation"
require "rom/command"
require "rom/plugins/command/schema"

RSpec.describe ROM::Plugins::Command::Schema do
  describe ".build" do
    let(:command_class) do
      Class.new(ROM::Command) { use :schema }
    end

    context "when relation has no schema defined" do
      let(:relation) do
        instance_double(ROM::Relation, schema?: false)
      end

      it "sets default input handler when command does not have a custom one" do
        command = Class.new(command_class).build(relation)

        expect(command.input).to be(ROM::Command.input)
      end

      it "sets custom input handler when command defines it" do
        my_handler = double(:my_handler)

        command = Class.new(command_class) { input my_handler }.build(relation)

        expect(command.input).to be(my_handler)
      end

      it "sets custom input handler when it is passed as an option" do
        my_handler = double(:my_handler)

        command = Class.new(command_class).build(relation, input: my_handler)

        expect(command.input).to be(my_handler)
      end
    end

    context "when relation has a schema" do
      let(:relation) do
        instance_double(ROM::Relation, schema?: true, input_schema: input_schema)
      end

      let(:input_schema) do
        double(:input_schema)
      end

      it "sets schema hash as input handler" do
        command = Class.new(command_class).build(relation)

        expect(command.input).to be(input_schema)
      end

      it "sets a composed input handler with schema hash and a custom one" do
        my_handler = double(:my_handler)

        command = Class.new(command_class) { input my_handler }.build(relation)

        expect(my_handler).to receive(:[]).with("some value").and_return("my handler")
        expect(input_schema).to receive(:[]).with("my handler").and_return("a tuple")

        expect(command.input["some value"]).to eql("a tuple")
      end
    end
  end
end
