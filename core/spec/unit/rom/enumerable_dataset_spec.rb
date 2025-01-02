# frozen_string_literal: true

require 'rom/enumerable_dataset'

RSpec.describe ROM::EnumerableDataset do
  let(:klass) do
    Class.new do
      include ROM::EnumerableDataset

      def self.row_proc
        -> i { i.transform_keys(&:to_sym) }
      end
    end
  end

  it_behaves_like 'an enumerable dataset'
end
