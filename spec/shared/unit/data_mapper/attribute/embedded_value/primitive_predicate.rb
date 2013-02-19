share_examples_for "Attribute::EmbeddedValue#primitive?" do
  subject { attribute.primitive? }

  let(:type)      { stub('type') }
  let(:attribute) { described_class.new(:name, :type => type) }

  it { should be(false) }
end
