# frozen_string_literal: true

require "rom/setup"

RSpec.describe ROM::Setup, "auto loading" do
  subject(:setup) do
    ROM::Setup.new(:memory)
  end

  let(:registry) do
    setup.registry
  end

  around do |example|
    example.run
  ensure
    zeitwerk_teardown
  end

  def zeitwerk_teardown
    Zeitwerk::Registry.loaders.each(&:unload)
    Zeitwerk::Registry.loaders.clear
    Zeitwerk::Registry.loaders_managing_gems.clear
    Zeitwerk::ExplicitNamespace.cpaths.clear
    Zeitwerk::ExplicitNamespace.tracer.disable
  end

  context "auto-loading with a namespace" do
    it "auto-loads relation definition file" do
      setup.auto_register(
        SPEC_ROOT.join("fixtures/auto_loading/persistence"), auto_load: false
      ).finalize

      expect(registry.relations[:tasks]).to be_a(Persistence::Relations::Tasks)
      expect(registry.mappers[:tasks][:listing]).to be_a(Persistence::Mappers::Tasks::Listing)
      expect(registry.commands[:tasks][:create]).to be_a(Persistence::Commands::Tasks::Create)
    end
  end

  context "auto-loading without a namespace" do
    it "auto-loads component definition files" do
      setup.auto_register(
        SPEC_ROOT.join("fixtures/auto_loading/app"), namespace: false, auto_load: true
      ).finalize

      expect(registry.relations[:users]).to be_a(Relations::Users)
      expect(registry.mappers[:users][:listing]).to be_a(Mappers::Users::Listing)
      expect(registry.commands[:users][:create]).to be_a(Commands::Users::Create)
    end
  end
end
