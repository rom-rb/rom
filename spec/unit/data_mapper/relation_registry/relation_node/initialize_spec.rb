require 'spec_helper'

describe RelationRegistry::RelationNode, '#initialize' do
  subject { object.new(name, relation) }

  let(:name)     { :songs }
  let(:relation) { mock_relation(:songs) }

  it_should_behave_like 'an abstract class'
end
