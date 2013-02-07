require 'spec_helper'

describe Environment, '#setup' do

  let(:object)  { described_class.new }
  let(:name)    { :test }
  let(:engine)  { mock }
  let(:options) { mock }

  all_specs_for_this_method = "#{described_class}#setup"

  shared_examples_for all_specs_for_this_method do
    it_should_behave_like 'a command method'

    it "should instantiate and register the engine with the given name" do
      subject.engines[name].should eql(engine)
    end
  end

  context "when options are given" do
    subject { object.setup(name, options) }

    before do
      Engine.should_receive(:build).with(options).and_return(engine)
    end

    it_should_behave_like all_specs_for_this_method
  end

  context "when no options are given" do
    subject { object.setup(name) }

    before do
      Engine.should_receive(:build).with(EMPTY_HASH).and_return(engine)
    end

    it_should_behave_like all_specs_for_this_method
  end
end
