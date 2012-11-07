require 'spec_helper'

# TODO remove this once abstract_class supports
# classes with different superclass from ::Object
describe RelationRegistry::RelationNode, '.new' do
  subject { object.new(name, relation) }

  let(:name)     { :songs }
  let(:relation) { mock_relation(:songs) }

  it_should_behave_like 'an abstract class'
end
