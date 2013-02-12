require 'spec_helper'

describe Engine, '#gateway_relation' do
  subject { object.gateway_relation(relation) }

  let(:object) { described_class.new('postgres://localhost/test') }

  let(:name)     { :users }
  let(:header)   { [[:id, Integer], [:name, String]] }
  let(:relation) { object.base_relation(name, header) }

  it { should be_instance_of(Veritas::Relation::Gateway) }
end
