require 'spec_helper'

describe RelationRegistry::JoinKeyMap, '#each' do
  let(:object)     { described_class.new(left_node, right_node, left_keys, right_keys) }
  let(:left_node)  { mock('left') }
  let(:right_node) { mock('right') }
  let(:left_keys)  { [:id] }
  let(:right_keys) { [:song_id] }

  context "with a block" do
    subject { object.each { |left, right| yields << [ left, right ] } }

    let(:yields) { [] }

    before do
      object.should be_instance_of(described_class)
    end

    it_should_behave_like 'an #each method'

    it 'yields each mapping' do
      expect { subject }.to change { yields.dup }.
        from([]).
        to([ [:id, :song_id] ])
    end
  end
end

describe RelationRegistry::JoinKeyMap do
  subject { described_class.new(left_node, right_node, left_keys, right_keys) }

  let(:object)     { described_class }
  let(:left_node)  { mock('left') }
  let(:right_node) { mock('right') }
  let(:left_keys)  { [:id] }
  let(:right_keys) { [:song_id] }

  before do
    subject.should be_instance_of(object)
  end

  it { should be_kind_of(Enumerable) }

  it 'case matches Enumerable' do
    (Enumerable === subject).should be(true)
  end
end
