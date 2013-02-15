require 'spec_helper'

describe Environment, '#setup' do
  subject { object.setup(name, options) }

  let(:object)     { described_class.new }
  let(:name)       { :test }
  let(:options)    { mock }
  let(:repository) { mock }

  before do
    Repository.should_receive(:coerce).with(name, options).and_return(repository)
  end

  it_should_behave_like 'a command method'

  it "should setup a repository" do
    subject.repository(name).should be(repository)
  end
end
