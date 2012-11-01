require 'spec_helper'

describe Relationship::OneToOne, "#default_target_key" do
  subject { object.default_target_key }

  let(:object)       { described_class.new(:name, source_model, target_model) }
  let(:source_model) { mock('source_model', :name => 'User') }
  let(:target_model) { mock('target_model', :name => 'Address') }

  it { should be(:user_id) }
end
