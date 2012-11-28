require 'spec_helper'

describe Mapper::Relation, '.aliases' do
  subject { object.aliases }

  let(:object) { Class.new(Mapper::Relation).relation_name(name) }
  let(:name)   { :users }

  it { should be_instance_of(Mapper::Relation::Aliases::Unary) }
end
