# encoding: utf-8

require 'spec_helper'

describe Relation, '#delete' do
  include_context 'Relation'

  subject { relation.delete(user1) }

  it { should be_instance_of(Relation) }

  it 'deletes tuples from the relation' do
    should_not include(user1)
  end
end
