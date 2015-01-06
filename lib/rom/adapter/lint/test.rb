module ROM
  class Adapter
    module Lint
      # This is a simple lint-test for an adapter class to ensure the basic
      # interfaces are in place
      #
      # @example
      #
      #   class MyAdapterTest < MiniTest::Test
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

        def test_schemes
          assert_respond_to adapter, :schemes,
            "#{adapter}.schemes must be implemented"

          assert_instance_of Array, adapter.schemes,
            "#{adapter}.schemes must return an array with supported URI schemes"

          assert adapter.schemes.size > 0,
            "#{adapter}.schemes must return at least one supported URI scheme"
        end

        def test_setup
          assert_instance_of adapter, adapter_instance
        end

        def test_dataset_reader
          assert_respond_to adapter_instance, :[]
        end

        def test_dataset_predicate
          assert_respond_to adapter_instance, :dataset?
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
      #  class MyDatasetLintTest < MiniTest::Test
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

        def test_each
          result = []
          dataset.each { |tuple| result << tuple }
          assert_equal result, data,
            "#{dataset.class}#each must yield tuples"
        end

        def test_to_a
          assert_equal dataset.to_a, data,
            "#{dataset.class}#to_a must cast dataset to an array"
        end
      end
    end
  end
end
