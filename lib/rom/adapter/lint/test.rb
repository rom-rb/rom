module ROM
  module Adapter
    module Lint
      # This is a simple lint-test for adapter's repository class to ensure the
      # basic interfaces are in place
      #
      # @example
      #
      #   class MyAdapterTest < Minitest::Test
      #     include ROM::Adapter::Lint::TestRepository
      #
      #     def repository_instance
      #       MyRepository.new("super_db://something")
      #     end
      #   end
      #
      # @public
      module TestRepository
        def test_schemes
          assert_respond_to repository, :schemes,
            "#{repository}.schemes must be implemented"

          assert_instance_of Array, repository.schemes,
            "#{repository}.schemes must return an array with supported URI schemes"

          assert repository.schemes.any?,
            "#{repository}.schemes must return at least one supported URI scheme"
        end

        def test_setup
          assert_instance_of repository, repository_instance
        end

        def test_dataset_reader
          assert_respond_to repository_instance, :[]
        end

        def test_dataset_predicate
          assert_respond_to repository_instance, :dataset?
        end

        def repository_instance
          fail(
            NotImplementedError,
            'Implement #repository_instance and return a repository instance'
          )
        end

        private

        def repository
          repository_instance.class
        end
      end

      # This is a simple lint-test for an repository dataset class to ensure the
      # basic behavior is correct
      #
      # @example
      #
      #  class MyDatasetLintTest < Minitest::Test
      #    include ROM::Repository::Lint::TestEnumerableDataset
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
