require 'spec_helper'
require 'data_mapper/engine/arel'

describe Engine::Arel::Engine, "#relation_node_class" do
  subject { object.relation_node_class }

  let(:object)       { described_class.new("foo://bar/baz", engine_class) }
  let(:engine_class) { mock('engine_class').as_null_object }

  it { should be(Engine::Arel::Node) }
end
