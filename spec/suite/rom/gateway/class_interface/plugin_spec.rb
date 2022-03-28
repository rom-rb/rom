# frozen_string_literal: true

require "rom/gateway"

RSpec.describe ROM::Gateway, ".plugin" do
  subject(:gateway) do
    Class.new(ROM::Gateway) do
      adapter :test
    end
  end

  it "defines a plugin for a given component type" do
    gateway.plugin(relations: :instrumentation) do |config|
      config.notifications = double(:notifications)
    end

    plugin = gateway.config.component.plugins.first

    expect(plugin).to_not be(nil)
    expect(plugin.name).to be(:instrumentation)
  end
end
