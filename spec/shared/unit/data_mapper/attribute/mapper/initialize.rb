shared_examples_for 'DataMapper::Mapper::Attribute::Mapper#initialize' do
  subject { described_class.new(name, options) }

  let(:name)    { :address }
  let(:options) { {} }

  context "when :type is not provided" do
    specify do
      expect { subject }.to raise_error(described_class::MissingTypeOptionError)
    end
  end
end
