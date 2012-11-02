require 'spec_helper'

describe Mapper::Relation, '.aliases' do
  subject { object.aliases }

  let(:object) { Class.new(Mapper::Relation).relation_name(name) }
  let(:name)   { :users }

  it { should be_instance_of(AliasSet) }

  its(:prefix) { should be(:user) }
end
