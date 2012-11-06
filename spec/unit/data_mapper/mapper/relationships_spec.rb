require 'spec_helper'

describe Mapper, '#relationships' do
  subject { object.relationships }

  let(:object)        { described_class.new }
  let(:relationships) { mock('relationships') }

  it 'delegates to self.class' do
    described_class.should_receive(:relationships).and_return(relationships)
    subject.should be(relationships)
  end
end
