require 'rom/enumerable_dataset'

RSpec.describe ROM::EnumerableDataset do
  let(:klass) do
    Class.new do
      include ROM::EnumerableDataset

      def self.row_proc
        -> i { i.each_with_object({}) { |(k, v), h| h[k.to_sym] = v } }
      end
    end
  end

  it_behaves_like 'an enumerable dataset'
end
