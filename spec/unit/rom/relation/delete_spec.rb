# encoding: utf-8

require 'spec_helper'

describe Relation, '#delete' do
  include_context 'Relation'

  subject { relation.delete(john) }

  it { should be_instance_of(Relation) }

  it 'deletes tuples from the relation' do
    should_not include(john)
  end
end
