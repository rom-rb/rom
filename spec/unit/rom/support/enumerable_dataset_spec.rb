require 'spec_helper'

require 'rom/support/enumerable_dataset'

describe ROM::EnumerableDataset do
  let(:klass) do
    Class.new do
      include ROM::EnumerableDataset

      def self.row_proc
        Transproc(:symbolize_keys)
      end
    end
  end

  it_behaves_like 'an enumerable dataset'
end
