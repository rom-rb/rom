require 'rom/registry'

RSpec.shared_examples_for 'registry fetch' do
  it 'raises an ArgumentError when nil is used as a key' do
    expect {
      registry.public_send(fetch_method, nil)
    }.to raise_error(ArgumentError, 'key cannot be nil')
  end

  it 'returns registered element identified by name' do
    expect(registry.public_send(fetch_method, :mars)).to be(mars)
  end

  it 'raises error when element is not found' do
    expect { registry.public_send(fetch_method, :twix) }.to raise_error(
      ROM::ElementNotFoundError,
      ":twix doesn't exist in Candy registry"
    )
  end

  it 'returns the value from an optional block when key is not found' do
    value = registry.public_send(fetch_method, :candy) { :twix }

    expect(value).to eq(:twix)
  end

  it 'calls #to_sym on a key before fetching' do
    expect(registry.public_send(fetch_method, double(to_sym: :mars))).to be(mars)
  end
end

RSpec.describe ROM::Registry do
  subject(:registry) { registry_class.build(mars: mars) }

  let(:mars) { double('mars') }

  let(:registry_class) do
    Class.new(ROM::Registry) do
      def self.name
        'Candy'
      end
    end
  end

  describe '#fetch' do
    let(:fetch_method) { :fetch }

    it_behaves_like 'registry fetch'
  end

  describe '#[]' do
    let(:fetch_method) { :[] }

    it_behaves_like 'registry fetch'
  end

  describe '#method_missing' do
    it 'returns registered element identified by name' do
      expect(registry.mars).to be(mars)
    end

    it 'raises no-method error when element is not there' do
      expect { registry.twix }.to raise_error(NoMethodError)
    end
  end

  describe '#key?' do
    let(:mars) { double(to_sym: :mars) }

    it 'calls #to_sym on a key before checking if it exists' do
      registry.key?(:mars)
    end

    it 'returns true for an existing key' do
      expect(registry.key?(:mars)).to be(true)
    end

    it 'returns false for a non-existing key' do
      expect(registry.key?(:twix)).to be(false)
    end

    it 'returns false for a nil key' do
      expect(registry.key?(nil)).to be(false)
    end
  end
end
