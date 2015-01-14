require "concord"

module ROM
  class Adapter
    module Lint

      def self.lint(adapter, uri)
        linter = Linter.new(adapter, uri)
        linter.lint
      end

      class Linter
        include Concord.new(:adapter, :uri)

        Failure = Class.new(StandardError) do
          # ship some extra information in the error
          include Concord::Public.new(:lint_name)
        end

        def self.linter_methods
          public_instance_methods(true).grep(/^lint_/).map(&:to_s)
        end

        def lint
          self.class.linter_methods.each do |name|
            public_send name
            puts "#{name}: ok"
          end
        end

        def TODO_lint_failure
          file Failure.new("test failure"),
               "#{adapter} is always failing here"
        end

        def lint_schemes
          return if adapter.respond_to? :schemes

          fail Failure.new("schemes"),
               "#{adapter}#schemes must be implemented"
        end

        def lint_schemes_is_an_array
          return if adapter.schemes.instance_of? Array

          fail Failure.new("schemes is an array"),
               "#{adapter}#schemes must return an array with supported URI schemes"
        end

        def lint_schemes_returns_any_supported_scheme
          return if adapter.schemes.any?

          fail Failure.new("schemes returns any supported scheme"),
               "#{adapter}#schemes must return at least one supported URI scheme"
        end

        def lint_adapter_setup
          return if adapter_instance.instance_of? adapter

          fail Failure.new("adapter setup"),
               "#{adapter}::setup must return an adapter instance"
        end

        def adapter_instance
          Adapter.setup(uri)
        end
      end
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

        # TODO: dataset lints
        def test_dataset_reader
          assert_respond_to adapter_instance, :[]
        end

        def test_dataset_predicate
          assert_respond_to adapter_instance, :dataset?
        end

        # Create test methods
        ROM::Adapter::Lint::Linter.linter_methods.each do |name|
          define_method "test_#{name}" do
            puts "testing #{name}"
            linter.public_send name
          end
        end

        private

        def linter
          ROM::Adapter::Lint::Linter.new(adapter, uri)
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
