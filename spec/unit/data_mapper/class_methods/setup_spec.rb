require 'spec_helper'

describe DataMapper, '.setup' do
  let(:repository) { :things }
  let(:uri)        { 'db://localhost/things'}

  context "when engine is not specified" do
    subject { DataMapper.setup(repository, uri) }

    it "sets up VeritasEngine by default" do
      subject.engines[repository].should be_instance_of(Engine::VeritasEngine)
    end
  end

  context "when engine is specified" do
    subject { DataMapper.setup(repository, uri, engine) }

    let(:engine) { Class.new(Engine) }

    it "sets up given engine" do
      subject.engines[repository].should be_instance_of(engine)
    end
  end
end
