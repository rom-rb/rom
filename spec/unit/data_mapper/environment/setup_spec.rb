require 'spec_helper'

describe Environment, '#setup' do
  subject { object.setup(name, uri) }

  let(:object)  { described_class.new }
  let(:name)    { :test }
  let(:engine)  { mock }
  let(:uri)     { 'something://somewhere/test' }

  before do
    Engine.should_receive(:new).with(uri).and_return(engine)
  end

  it_should_behave_like 'a command method'

  it "should instantiate and register the engine with the given name" do
    subject.engines[name].should eql(engine)
  end
end
