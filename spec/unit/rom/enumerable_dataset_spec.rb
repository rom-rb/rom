require 'spec_helper'

require 'rom/enumerable_dataset'

describe ROM::EnumerableDataset do
  let(:klass) do
    Class.new do
      include ROM::EnumerableDataset

      def self.tuple_proc
        Transproc(:symbolize_keys)
      end
    end
  end

  it_behaves_like 'an enumerable dataset'
end
