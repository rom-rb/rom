require 'spec_helper'

describe "ROM::PluginRegistry" do

  subject(:env) { setup.finalize }

  let(:setup) { ROM.setup(:memory) }

  before do
    GlobalExtension = Module.new

    setup.relation(:users)

    setup.plugins do
      register :publisher, GlobalExtension, type: :command
    end
  end


  it "makes global plugins available" do
    class TestCommand < ROM::Commands::Create[:memory]
      relation :users
      register_as :create
      use :publisher
    end

    expect(env.command(:users).create).to be_kind_of GlobalExtension
  end



end
