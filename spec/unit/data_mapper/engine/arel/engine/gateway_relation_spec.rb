require 'spec_helper'
require 'data_mapper/engine/arel'

describe Engine::Arel::Engine, "#gateway_relation" do
  subject { object.gateway_relation(relation) }

  let(:object)       { described_class.new("foo://bar/baz", engine_class) }
  let(:engine_class) { mock('engine_class').as_null_object }

  let(:relation) { mock('relation') }

  it { should be_instance_of(Engine::Arel::Gateway) }
end
