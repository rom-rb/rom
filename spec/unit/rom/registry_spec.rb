require 'spec_helper'

describe ROM::Registry do
  subject(:registry) { registry_class.new(mars: mars) }

  let(:mars) { double('mars') }

  let(:registry_class) do
    Class.new(ROM::Registry) do
      def self.name
        'Candy'
      end
    end
  end

  describe '#fetch' do
    it 'returns registered elemented identified by name' do
      expect(registry[:mars]).to be(mars)
    end

    it 'raises error when element is not found' do
      expect { registry[:twix] }.to raise_error(
        ROM::Registry::ElementNotFoundError,
        ":twix doesn't exist in Candy registry"
      )
    end
  end

  describe '.element_name' do
    it 'returns registered elemented identified by element_name' do
      expect(registry[:mars]).to be(mars)
    end

    it 'raises no-method error when element is not there' do
      expect { registry.twix }.to raise_error(NoMethodError)
    end
  end
end
