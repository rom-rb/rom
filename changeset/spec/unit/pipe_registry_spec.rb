# frozen_string_literal: true

RSpec.describe ROM::Changeset::PipeRegistry do
  describe '.add_timestamps' do
    context 'input has no timestamps' do
      let(:data) { Hash(name: 'John') }

      it 'adds timestamps to hash' do
        expect(described_class.add_timestamps(data)[:name]).to eq('John')

        expect(described_class.add_timestamps(data)[:created_at]).to be_a(Time)
        expect(described_class.add_timestamps(data)[:updated_at]).to be_a(Time)
      end
    end

    context 'input has (some) timestamps' do
      let(:data) { Hash(name: 'John', created_at: :timestamp) }

      it 'preserves original values' do
        expect(described_class.add_timestamps(data)[:name]).to eq('John')
        expect(described_class.add_timestamps(data)[:created_at]).to eq(:timestamp)
      end

      it 'adds missing values' do
        expect(described_class.add_timestamps(data)[:name]).to eq('John')
        expect(described_class.add_timestamps(data)[:updated_at]).to be_a(Time)
      end
    end
  end

  describe '.touch' do
    context 'input has no updated timestamp' do
      let(:data) { Hash(name: 'John') }

      it 'adds updated_at timestamp to hash' do
        expect(described_class.touch(data)[:name]).to eq('John')

        expect(described_class.touch(data)[:created_at]).to be_nil
        expect(described_class.touch(data)[:updated_at]).to be_a(Time)
      end
    end

    context 'input has updated_at timestamp' do
      let(:data) { Hash(name: 'John', updated_at: :timestamp) }

      it 'preserves original values' do
        expect(described_class.touch(data)[:name]).to eq('John')
        expect(described_class.touch(data)[:updated_at]).to eq(:timestamp)
      end
    end
  end
end
