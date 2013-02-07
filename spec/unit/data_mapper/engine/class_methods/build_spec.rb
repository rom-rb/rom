require 'spec_helper'

describe Engine, '.build' do
  subject { described_class.build(options) }

  let(:engine)  { Class.new(described_class) }
  let(:uri)     { "something://somewhere/test" }
  let(:options) { { :uri => uri, :engine => engine_name } }

  context "when the desired engine is not registered" do
    let(:engine_name) { mock }

    specify do
      expect { subject }.to raise_error(
        Engine::MissingEngineError,
        "#{engine_name.inspect} has not been registered"
      )
    end
  end

  context "when the desired engine is registered" do
    let(:registered_name) { :in_memory }
    let(:engine_name)     { registered_name }

    before do
      engine.register_as(registered_name)
    end

    context "and the engine can be required" do
      it        { should be_instance_of(engine) }
      its(:uri) { should eql(Addressable::URI.parse(uri)) }
    end

    context "when the engine cannot be required" do
      let(:registered_name) { :'notthereforsure' }

      specify do
        expect { subject }.to raise_error(LoadError)
      end
    end
  end
end
