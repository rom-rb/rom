require 'spec_helper'

require 'rom/array_dataset'

describe ROM::ArrayDataset do
  let(:klass) do
    Class.new do
      include ROM::ArrayDataset

      def self.row_proc
        Transproc(:symbolize_keys)
      end
    end
  end

  it_behaves_like 'an enumerable dataset'
end
