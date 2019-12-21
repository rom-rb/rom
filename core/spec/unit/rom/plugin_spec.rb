require 'spec_helper'

RSpec.describe "ROM::PluginRegistry" do
  include_context 'container'

  before do
    Test::ConfigurationPlugin = Module.new
    Test::CommandPlugin     = Module.new
    Test::MapperPlugin      = Module.new
    Test::RelationPlugin    = Module.new do
      def plugged_in
        "a relation"
      end
    end
    Test::SchemaPlugin = Module.new do
      def self.apply(schema, **)
        schema.attributes.concat(
          [ROM::Attribute.new(ROM::Types::Date.meta(source: schema.name), name: :created_at),
           ROM::Attribute.new(ROM::Types::Date.meta(source: schema.name), name: :updated_at)]
        )
      end
    end
    Test::SchemaDSLExt = Module.new
    Test::SchemaDSLExt::DSL = Module.new do
      def build_type(*)
        super.meta(plugged_in: true)
      end
    end

    ROM.plugins do
      register :registration,   Test::ConfigurationPlugin, type: :configuration
      register :publisher,      Test::CommandPlugin,       type: :command
      register :pager,          Test::RelationPlugin,      type: :relation
      register :translater,     Test::MapperPlugin,        type: :mapper
      register :datestamps,     Test::SchemaPlugin,        type: :schema
      register :schema_dsl_ext, Test::SchemaDSLExt,        type: :schema
    end

    configuration
  end

  around do |example|
    orig_plugins = ROM.plugin_registry
    example.run
    ROM.instance_variable_set('@plugin_registry', orig_plugins)
  end

  it "makes configuration plugins available" do
    expect(ROM.plugin_registry[:configuration].fetch(:registration).mod)
      .to eq Test::ConfigurationPlugin
  end

  it "includes relation plugins" do
    users = Class.new(ROM::Relation[:memory]) do
      schema(:users) { }
      use :pager
    end
    configuration.register_relation(users)

    expect(container.relations[:users].plugged_in).to eq "a relation"
  end

  it "makes command plugins available" do
    users = Class.new(ROM::Relation[:memory]) do
      schema(:users) { }
    end

    create_user = Class.new(ROM::Commands::Create[:memory]) do
      relation :users
      register_as :create
      use :publisher
    end

    configuration.register_relation(users)
    configuration.register_command(create_user)

    expect(container.commands[:users].create).to be_kind_of Test::CommandPlugin
  end

  it "includes plugins in mappers" do
    users = Class.new(ROM::Relation[:memory]) do
      schema(:users) { }
    end
    translator = Class.new(ROM::Mapper) do
      relation :users
      register_as :translator
      use :translater
    end

    configuration.register_relation(users)
    configuration.register_mapper(translator)

    expect(container.mappers[:users][:translator]).to be_kind_of Test::MapperPlugin
  end

  it "restricts plugins to defined type" do
    expect {
      configuration.relation(:users) do
        use :publisher
      end
    }.to raise_error ROM::UnknownPluginError
  end

  it "allows definition of adapter restricted plugins" do
    Test::LazyPlugin = Module.new do
      def lazy?
        true
      end
    end

    ROM.plugins do
      adapter :memory do
        register :lazy, Test::LazyPlugin, type: :relation
      end
    end

    users = Class.new(ROM::Relation[:memory]) do
      schema(:users) { }
      use :lazy
    end
    configuration.register_relation(users)

    expect(container.relations[:users]).to be_lazy
  end

  it "respects adapter restrictions" do
    Test::LazyPlugin = Module.new
    Test::LazyMemoryPlugin = Module.new
    Test::LazySQLPlugin = Module.new

    ROM.plugins do
      register :lazy, Test::LazyPlugin, type: :command

      adapter :memory do
        register :lazy_command, Test::LazyMemoryPlugin, type: :command
      end

      adapter :sql do
        register :lazy, Test::LazySQLPlugin, type: :command
      end
    end

    users = Class.new(ROM::Relation[:memory]) do
      schema(:users) { }
    end

    create_user = Class.new(ROM::Commands::Create[:memory]) do
      relation :users
      register_as :create
      use :lazy
    end

    update_user = Class.new(ROM::Commands::Update[:memory]) do
      relation :users
      register_as :update
      use :lazy_command
    end

    configuration.register_relation(users)
    configuration.register_command(create_user)
    configuration.register_command(update_user)

    expect(container.commands[:users].create).not_to be_kind_of Test::LazySQLPlugin
    expect(container.commands[:users].create).to be_kind_of Test::LazyPlugin
    expect(container.commands[:users].update).to be_kind_of Test::LazyMemoryPlugin
  end

  it 'applies plugins to schemas' do
    rel_name = ROM::Relation::Name[:users]

    users = ROM::Schema::DSL.new(rel_name) {
      attribute :id, ROM::Types::Integer
      attribute :name, ROM::Types::String

      use :datestamps
    }.call

    expect(users.to_h.keys).to eql %i(id name created_at updated_at)
  end

  it 'applies extensions to schema DSL' do
    rel_name = ROM::Relation::Name[:users]

    users = ROM::Schema::DSL.new(rel_name) {
      use :schema_dsl_ext

      attribute :id, ROM::Types::Integer
    }.call

    expect(users[:id].meta[:plugged_in]).to be true
  end
end
