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
    # From zeitwerk's own test/support/loader_test
    # adjusted to work with dry-rb gem loaders

    Zeitwerk::Registry.loaders.reject! do |loader|
      test_loader = loader.dirs.any? { |dir| dir.include?("/spec/") || dir.include?(Dir.tmpdir) }

      if test_loader
        loader.unregister
        true
      else
        false
      end
    end
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
