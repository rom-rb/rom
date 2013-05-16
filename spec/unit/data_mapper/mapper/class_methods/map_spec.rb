require 'spec_helper'

describe DataMapper::Mapper, '.map' do
  subject { object.map(name, options) }

  let(:object)  { described_class }
  let(:name)    { :title }
  let(:options) { { :to => :book_title } }

  before do
    object.attributes.should_receive(:add).with(name, options)
  end

  it_should_behave_like 'a command method'
end
