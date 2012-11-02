require 'spec_helper'

describe Engine::VeritasEngine, '#base_relation' do
  subject { object.base_relation(name, header) }

  let(:object) { described_class.new('postgres://localhost/test') }

  let(:name)   { :users }
  let(:header) { [[:id, Integer], [:name, String]] }

  it { should be_instance_of(Veritas::Relation::Base) }

  its(:name) { should eql(name.to_s) }
end
