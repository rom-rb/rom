require 'spec_helper'

describe Engine, '#initialize' do
  subject { object.new }

  it_should_behave_like 'an abstract class'
end
