require 'spec_helper'

require 'rom/support/array_dataset'

describe ROM::ArrayDataset do
  let(:klass) do
    Class.new do
      include ROM::ArrayDataset

      def self.row_proc
        Transproc(:symbolize_keys)
      end
    end
  end

  it_behaves_like 'an enumerable dataset' do
    describe '#flatten' do
      let(:data) { [[{ 'name' => 'Jane' }], [{ 'name' => 'Joe' }]] }

      it 'returns a new dataset with flattened data' do
        result = dataset.flatten

        expect(result).to match_array([{ name: 'Jane' }, { name: 'Joe' }])
      end
    end

    describe '#map!' do
      context 'with a block' do
        it 'returns a new dataset with mapped data' do
          dataset.map! { |row| row.merge(age: 21) }

          expect(dataset).to match_array([
            { name: 'Jane', age: 21 }, { name: 'Joe', age: 21 }
          ])
        end
      end

      context 'without a block' do
        it 'returns an enumerator' do
          result = dataset.map!

          expect(result).to be_instance_of(Enumerator)

          expect(result).to match_array([
            { name: 'Jane' }, { name: 'Joe' }
          ])
        end
      end
    end

    describe '#values_at' do
      it 'returns a new dataset with rows at given indices' do
        result = dataset.values_at(1)

        expect(result).to match_array([{ name: 'Joe' }])
      end
    end
  end
end
