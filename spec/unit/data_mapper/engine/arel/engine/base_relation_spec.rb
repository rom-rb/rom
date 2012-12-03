require 'spec_helper'
require 'data_mapper/engine/arel'

describe Engine::Arel::Engine, "#base_relation" do
  subject { object.base_relation(name, header) }

  let(:object)       { described_class.new("foo://bar/baz", engine_class) }
  let(:engine_class) { mock('engine_class').as_null_object }

  let(:name)   { :users }
  let(:header) { [] }

  let(:users_engine) { mock('users_engine') }

  before do
    object.stub!(:arel_engine_for).with(name, header).
      and_return(users_engine)
  end

  it { should be_instance_of(Arel::Table) }

  its(:engine) { should be(users_engine) }
end
