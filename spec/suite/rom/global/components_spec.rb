# frozen_string_literal: true

require "rom/core"

RSpec.describe ROM, ".components" do
  let(:components) do
    ROM.components
  end

  around do |example|
    components.keys.tap do |keys|
      example.run
      (components.keys - keys).each { |key| components._container.delete(key) }
    end
  end

  it "registers a component handler with default key and namespace" do
    module Test
      class Serializer
      end
    end

    ROM.components do
      register(:serializer, Test::Serializer)
    end

    expect(components[:serializer].key).to be(:serializer)
    expect(components[:serializer].namespace).to be(:serializers)
    expect(components[:serializer].constant).to be(Test::Serializer)
  end
end
