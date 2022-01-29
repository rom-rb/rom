# frozen_string_literal: true

require "rom/runtime"

RSpec.describe ROM::Runtime, "auto loading" do
  subject(:runtime) do
    ROM::Runtime.new(:memory)
  end

  let(:resolver) do
    runtime.resolver
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
      runtime.auto_register(
        SPEC_ROOT.join("fixtures/auto_loading/persistence"), auto_load: false
      ).finalize

      expect(resolver.relations[:tasks]).to be_a(Persistence::Relations::Tasks)
      expect(resolver.mappers[:tasks][:listing]).to be_a(Persistence::Mappers::Tasks::Listing)
      expect(resolver.commands[:tasks][:create]).to be_a(Persistence::Commands::Tasks::Create)
    end
  end

  context "auto-loading without a namespace" do
    it "auto-loads component definition files" do
      runtime.auto_register(
        SPEC_ROOT.join("fixtures/auto_loading/app"), namespace: false, auto_load: true
      ).finalize

      expect(resolver.relations[:users]).to be_a(Relations::Users)
      expect(resolver.mappers[:users][:listing]).to be_a(Mappers::Users::Listing)
      expect(resolver.commands[:users][:create]).to be_a(Commands::Users::Create)
    end
  end
end
