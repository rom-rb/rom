require 'spec_helper'

describe Relation::Graph::Node, '#each' do
  let(:object)   { subclass.new(name, relation) }
  let(:name)     { :users }
  let(:relation) { mock('relation') }

  context "with a block" do
    subject { object.each(&block) }

    let(:block) { Proc.new {} }

    it 'delegates to relation' do
      relation.should_receive(:each).with(&block)
      subject
    end
  end

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end
end
