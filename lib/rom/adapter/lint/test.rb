require 'rom/adapter/lint/common'

module ROM
  class Adapter
    module Lint
      # This is a simple lint-test for an adapter class to ensure the basic
      # interfaces are in place
      #
      # @example
      #
      #   class MyAdapterTest < Minitest::Test
      #     include ROM::Adapter::Lint::TestAdapter
      #
      #     def setup
      #       @adapter = MyAdapter
      #       @uri = "super_db://something"
      #     end
      #   end
      #
      # @public
      module TestAdapter
        attr_reader :adapter, :uri

        CommonAdapter.each do |name, block|
          define_method("test_#{name}", &block)
        end

        private

        def adapter_instance
          Adapter.setup(uri)
        end
      end

      # This is a simple lint-test for an adapter dataset class to ensure the
      # basic behavior is correct
      #
      # @example
      #
      #  class MyDatasetLintTest < Minitest::Test
      #    include ROM::Adapter::Lint::TestEnumerableDataset
      #
      #     def setup
      #       @data  = [{ name: 'Jane', age: 24 }, { name: 'Joe', age: 25 }]
      #       @dataset = MyDataset.new(@data, [:name, :age])
      #     end
      #   end
      # @public
      module TestEnumerableDataset
        attr_reader :dataset, :data

        CommonEnumerableDataset.each do |name, block|
          define_method("test_#{name}", &block)
        end
      end
    end
  end
end
