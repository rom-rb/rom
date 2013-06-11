require 'spec_helper'

describe Graph::Node, '#each' do
  let(:object)   { described_class.new(name, relation) }
  let(:name)     { :users }

  fake(:relation)

  context "with a block" do
    subject { object.each(&block) }

    let(:block) { Proc.new {} }

    it 'delegates to relation' do
      subject
      relation.should have_received.each(&block)
    end
  end

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end
end
