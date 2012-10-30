require 'spec_helper'

describe Relationship::Options::OneToMany, "#validator_class" do
  subject { object.validator_class }

  let(:object)       { described_class.new(:name, source_model, target_model) }
  let(:source_model) { mock('source_model', :name => 'User') }
  let(:target_model) { mock('target_model', :name => 'Address') }

  it { should be(Relationship::Options::Validator::OneToMany) }
end
