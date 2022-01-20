# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Mapper Setup" do
  include_context "container"

  before do
    configuration.mappers do
      define(:users_mapper) do
        attribute :id
      end

      define(:tags_mapper) do
        attribute :user_id
        attribute :label
      end
    end
  end

  it "accessible through register_as with the same name as use in the define method" do
    expect(configuration.components.mappers.map(&:id)).to eql(%i[users_mapper tags_mapper])
  end
end
