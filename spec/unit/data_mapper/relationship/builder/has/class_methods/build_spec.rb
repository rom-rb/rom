require 'spec_helper'

describe Relationship::Builder::Has, '.build' do
  subject { described_class.build(source, cardinality, name, target_model, options) }

  let(:source)       { mock_mapper(source_model) }
  let(:source_model) { mock_model(:User) }
  let(:target_model) { mock_model(:Address) }
  let(:cardinality)  { 1 }
  let(:name)         { :address }
  let(:options)      { {} }

  its(:name)         { should be(name) }
  its(:source_model) { should be(source_model) }
  its(:target_model) { should be(target_model) }

  context "when cardinality is 1" do
    it { should be_instance_of(Relationship::OneToOne) }
  end

  context "when cardinality is > 1" do
    let(:cardinality)  { 2 }

    context "when :through is not set" do
      it { should be_instance_of(Relationship::OneToMany) }
    end

    context "when :through is set" do
      before { options[:through] = :other }

      it { should be_instance_of(Relationship::ManyToMany) }
    end
  end

  context "when cardinality is a range" do
    let(:cardinality)  { 2..4 }

    context "when :through is not set" do
      it { should be_instance_of(Relationship::OneToMany) }
    end

    context "when :through is set" do
      before { options[:through] = :other }

      it { should be_instance_of(Relationship::ManyToMany) }
    end
  end

  context "when cardinality is an invalid value" do
    let(:cardinality) { :foo }

    specify do
      expect { subject }.to raise_error(
        ArgumentError,
        'Rom::Relationship::Builder::Has.has(foo, :address, ...): must be Integer or Range but was Symbol'
      )
    end
  end
end
