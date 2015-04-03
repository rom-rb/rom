require 'spec_helper'

describe "ROM::PluginRegistry" do

  subject(:env) { setup.finalize }

  let(:setup) { ROM.setup(:memory) }

  before do
    Test::CommandPlugin   = Module.new
    Test::RelationPlugin  = Module.new do
      def self.included(mod)
        mod.exposed_relations << :plugged_in
      end

      def plugged_in
        "a relation"
      end
    end

    setup.plugins do
      register :publisher, Test::CommandPlugin,   type: :command
      register :pager,  Test::RelationPlugin,  type: :relation
    end

  end

  it "includes relation plugins" do
    setup.relation(:users) do
      use :pager
    end

    expect(env.relation(:users).plugged_in).to eq "a relation"
  end


  it "makes global plugins available" do
    setup.relation(:users)

    test_class = Class.new(ROM::Commands::Create[:memory]) do
      relation :users
      register_as :create
      use :publisher
    end

    expect(env.command(:users).create).to be_kind_of Test::CommandPlugin
  end






end
