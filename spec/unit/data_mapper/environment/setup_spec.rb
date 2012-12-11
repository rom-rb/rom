require 'spec_helper'

describe Environment, '#setup' do
  let!(:engine)  { Class.new(Engine).register_as(:limbo) }

  let(:name)    { :somerepo }
  let(:uri)     { "something://somewhere/test" }

  after(:all) {
    Engine.engines.delete(:somerepo)
  }

  context "when engine name is not provided" do
    let(:options) { { :uri => uri, :engine => nil } }

    it "initializes default engine" do
      subject.setup(name, options)
      expect(subject.engines[:somerepo]).to be_instance_of(Engine.default)
    end
  end

  context "when engine name is provided" do
    let(:options) { { :uri => uri, :engine => :limbo } }

    it "initializes engine identified by :engine option" do
      subject.setup(name, options)
      expect(subject.engines[:somerepo]).to be_instance_of(engine)
    end
  end

  context "when engine cannot be found" do
    let(:options) { { :uri => uri, :engine => '#nothereforsure#' } }

    it "raises exception" do
      expect { subject.setup(name, options) }.to raise_error(
        Engine::MissingEngineError,
        '"#nothereforsure#" is not a correct engine identifier'
      )
    end
  end
end
