shared_examples_for 'an abstract type' do
  context 'called on a subclass' do
    let(:object) { Class.new(described_class) }

    it { should be_instance_of(object) }
  end

  context 'called on the class' do
    let(:object) { described_class }

    specify { expect { subject }.to raise_error(NotImplementedError, "#{object} is an abstract type") }
  end
end
