require 'spec_helper'

describe Engine::Veritas::Node, '#rename' do
  subject { object.rename(new_aliases) }

  let(:new_aliases) { { :id => :foo_id } }

  let(:object)   { described_class.new(name, relation, aliases) }
  let(:name)     { :users }
  let(:relation) { mock('relation') }
  let(:aliases)  { Relation::Aliases.new(index) }
  let(:index)    { Relation::Aliases::Index.new({ attribute_alias(:id, :users) => attribute_alias(:id, :users) }, strategy) }
  let(:strategy) { Relation::Graph::Node.send(:aliasing_strategy) }

  let(:renamed_aliases) { aliases.rename(new_aliases) }

  before do
    relation.should_receive(:rename).with(renamed_aliases).and_return(relation)
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(relation) }
  its(:aliases)  { should eql(renamed_aliases) }
end
