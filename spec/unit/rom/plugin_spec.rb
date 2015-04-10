require 'spec_helper'

describe "ROM::PluginRegistry" do

  subject(:env) { setup.finalize }

  let(:setup) { ROM.setup(:memory) }

  before do
    Test::CommandPlugin   = Module.new
    Test::MapperPlugin    = Module.new
    Test::RelationPlugin  = Module.new do
      def self.included(mod)
        mod.exposed_relations << :plugged_in
      end

      def plugged_in
        "a relation"
      end
    end

    setup.plugins do
      register :publisher,  Test::CommandPlugin,  type: :command
      register :pager,      Test::RelationPlugin, type: :relation
      register :translater, Test::MapperPlugin,   type: :mapper
    end

  end

  it "includes relation plugins" do
    setup.relation(:users) do
      use :pager
    end

    expect(env.relation(:users).plugged_in).to eq "a relation"
  end


  it "makes command plugins available" do
    setup.relation(:users)

    test_class = Class.new(ROM::Commands::Create[:memory]) do
      relation :users
      register_as :create
      use :publisher
    end

    expect(env.command(:users).create).to be_kind_of Test::CommandPlugin
  end

  it "inclues plugins in mappers" do
    setup.relation(:users)

    test_class = Class.new(ROM::Mapper) do
      relation :users
      register_as :translator
      use :translater
    end

    expect(env.mappers[:users][:translator]).to be_kind_of Test::MapperPlugin
  end

  it "restricts plugins to defined type" do
    expect { 
      setup.relation(:users) do
        use :publisher
      end
    }.to raise_error ROM::UnknownPluginError
  end


  it "allows definition of adapter restricted plugins" do
    Test::LazyPlugin = Module.new do
      def self.included(mod)
        mod.exposed_relations << :lazy?
      end

      def lazy?
        true
      end
    end

    setup.plugins do
      adapter :memory do
        register :lazy, Test::LazyPlugin, type: :relation
      end
    end

    setup.relation(:users) do
      use :lazy
    end

    expect(env.relation(:users)).to be_lazy
  end


end
