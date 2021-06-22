# frozen_string_literal: true

require "rom/configuration"
require "rom/transformer"

RSpec.describe ROM::Configuration, "#auto_register" do
  subject(:setup) { ROM::Configuration.new }

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

  context "with default component dirs and namespace turned on" do
    it "loads files and returns constants" do
      setup.auto_register(SPEC_ROOT.join("fixtures/lib/persistence")).finalize

      expect(setup.components.relations.map(&:constant)).to eql([Persistence::Relations::Users])
      expect(setup.components.commands.map(&:constant)).to eql([Persistence::Commands::CreateUser])
      expect(setup.components.mappers.map(&:constant)).to eql([Persistence::Mappers::UserList])
    end
  end

  context "with custom component dirs and namespace turned on" do
    it "loads files and returns constants" do
      setup.auto_register(
        SPEC_ROOT.join("fixtures/lib/persistence"),
        component_dirs: {
          relations: :my_relations,
          mappers: :my_mappers,
          commands: :my_commands
        }
      ).finalize

      expect(setup.components.relations.map(&:constant)).to eql([Persistence::MyRelations::Users])
      expect(setup.components.commands.map(&:constant)).to eql([Persistence::MyCommands::CreateUser])
      expect(setup.components.mappers.map(&:constant)).to eql([Persistence::MyMappers::UserList])
    end
  end

  context "with default component dirs and namespace set explicitly" do
    it "loads files and returns constants" do
      setup.auto_register(SPEC_ROOT.join("fixtures/explicit"), namespace: Test).finalize

      expect(setup.components.relations.map(&:constant)).to eql([Test::Relations::Users])
      expect(setup.components.commands.map(&:constant)).to eql([Test::Commands::CreateUser])
      expect(setup.components.mappers.map(&:constant)).to eql([Test::Mappers::UserList])
    end
  end

  context "with custom component dirs and namespace set explicitly" do
    it "loads files and returns constants" do
      setup.auto_register(
        SPEC_ROOT.join("fixtures/explicit_custom"),
        component_dirs: {
          relations: :my_relations,
          mappers: :my_mappers,
          commands: :my_commands
        },
        namespace: Test
      ).finalize

      expect(setup.components.relations.map(&:constant)).to eql([Test::MyRelations::Users])
      expect(setup.components.commands.map(&:constant)).to eql([Test::MyCommands::CreateUser])
      expect(setup.components.mappers.map(&:constant)).to eql([Test::MyMappers::UserList])
    end
  end

  context "with default component dirs and namespace turned off" do
    it "loads files and returns constants" do
      setup.auto_register(SPEC_ROOT.join("fixtures/app/persistence"), namespace: false).finalize

      expect(setup.components.relations.map(&:constant)).to eql([Relations::Users])
      expect(setup.components.commands.map(&:constant)).to eql([Commands::CreateUser])
      expect(setup.components.mappers.map(&:constant)).to eql([Mappers::UserList])
    end
  end

  context "with custom component dirs and namespace turned off" do
    it "loads files and returns constants" do
      setup.auto_register(
        SPEC_ROOT.join("fixtures/app/persistence"),
        component_dirs: {
          relations: :my_relations,
          mappers: :my_mappers,
          commands: :my_commands
        },
        namespace: false
      ).finalize

      expect(setup.components.relations.map(&:constant)).to eql([MyRelations::Users])
      expect(setup.components.commands.map(&:constant)).to eql([MyCommands::CreateUser])
      expect(setup.components.mappers.map(&:constant)).to eql([MyMappers::UserList])
    end
  end

  context "with custom component dirs and a customized inflector" do
    let(:inflector) do
      Dry::Inflector.new do |i|
        i.acronym("XML")
      end
    end

    it "loads files and returns constants" do
      inflector.extend(ROM::ZeitwerkCompatibility)

      setup.auto_register(
        SPEC_ROOT.join("fixtures/custom/xml_space"),
        inflector: inflector,
        component_dirs: {
          relations: :xml_relations,
          mappers: :xml_mappers,
          commands: :xml_commands
        }
      ).finalize

      expect(setup.components.relations.map(&:constant)).to eql([XMLSpace::XMLRelations::Customers])
      expect(setup.components.commands.map(&:constant)).to eql([XMLSpace::XMLCommands::CreateCustomer])
      expect(setup.components.mappers.map(&:constant)).to eql([XMLSpace::XMLMappers::CustomerList])
    end
  end
end
