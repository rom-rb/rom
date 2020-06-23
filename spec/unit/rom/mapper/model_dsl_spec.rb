# frozen_string_literal: true

require "spec_helper"

RSpec.describe ROM::Mapper::ModelDSL do
  describe "#model" do
    it "calls the builder with non-excluded attributes only" do
      definition_class = Class.new do
        include ROM::Mapper::ModelDSL

        def initialize
          @attributes = [[:name], [:title, {exclude: true}]]
          @builder = ->(attrs) { Struct.new(*attrs) }
        end
      end
      model_instance = definition_class.new.model.new
      expect(model_instance).to respond_to(:name)
      expect(model_instance).to_not respond_to(:title)
    end
  end
end
