require 'spec_helper'

describe Engine, '#adapter' do
  subject { object.adapter }

  let(:object) { subclass.new }

  it { should be(nil) }
end
