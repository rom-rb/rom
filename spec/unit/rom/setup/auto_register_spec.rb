# frozen_string_literal: true

require "rom/setup"
require "rom/support/notifications"

RSpec.describe ROM::Setup, "#auto_register" do
  subject(:setup) { ROM::Setup.new(notifications) }

  let(:notifications) { instance_double(ROM::Notifications::EventBus) }

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
      setup.auto_register(SPEC_ROOT.join("fixtures/lib/persistence"))

      expect(setup.relation_classes).to eql([Persistence::Relations::Users])
      expect(setup.command_classes).to eql([Persistence::Commands::CreateUser])
      expect(setup.mapper_classes).to eql([Persistence::Mappers::UserList])
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
      )

      expect(setup.relation_classes).to eql([Persistence::MyRelations::Users])
      expect(setup.command_classes).to eql([Persistence::MyCommands::CreateUser])
      expect(setup.mapper_classes).to eql([Persistence::MyMappers::UserList])
    end
  end

  context "with default component dirs and namespace set explicitly" do
    it "loads files and returns constants" do
      setup.auto_register(SPEC_ROOT.join("fixtures/explicit"), namespace: Test)

      expect(setup.relation_classes).to eql([Test::Relations::Users])
      expect(setup.command_classes).to eql([Test::Commands::CreateUser])
      expect(setup.mapper_classes).to eql([Test::Mappers::UserList])
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
      )

      expect(setup.relation_classes).to eql([Test::MyRelations::Users])
      expect(setup.command_classes).to eql([Test::MyCommands::CreateUser])
      expect(setup.mapper_classes).to eql([Test::MyMappers::UserList])
    end
  end

  context "with default component dirs and namespace turned off" do
    it "loads files and returns constants" do
      setup.auto_register(SPEC_ROOT.join("fixtures/app/persistence"), namespace: false)

      expect(setup.relation_classes).to eql([Relations::Users])
      expect(setup.command_classes).to eql([Commands::CreateUser])
      expect(setup.mapper_classes).to eql([Mappers::UserList])
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
      )

      expect(setup.relation_classes).to eql([MyRelations::Users])
      expect(setup.command_classes).to eql([MyCommands::CreateUser])
      expect(setup.mapper_classes).to eql([MyMappers::UserList])
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
      )

      expect(setup.relation_classes).to eql([XMLSpace::XMLRelations::Customers])
      expect(setup.command_classes).to eql([XMLSpace::XMLCommands::CreateCustomer])
      expect(setup.mapper_classes).to eql([XMLSpace::XMLMappers::CustomerList])
    end
  end
end
