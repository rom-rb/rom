# frozen_string_literal: true

require 'rom/lint/gateway'
require 'rom/lint/enumerable_dataset'

module ROM
  module Lint
    # A module that helps to define test methods
    module Test
      # Defines a test method converting lint failures to assertions
      #
      # @param [String] name
      #
      # @api private
      def define_test_method(name, &block)
        define_method "test_#{name}" do
          begin
            instance_eval(&block)
          rescue ROM::Lint::Linter::Failure => f
            raise Minitest::Assertion, f.message
          end
        end
      end
    end

    # This is a simple lint-test for gateway class to ensure the
    # basic interfaces are in place
    #
    # @example
    #
    #   class MyGatewayTest < Minitest::Test
    #     include ROM::Lint::TestGateway
    #
    #     def setup
    #       @gateway = MyGateway
    #       @uri = "super_db://something"
    #     end
    #   end
    #
    # @api public
    module TestGateway
      extend ROM::Lint::Test

      # Returns the gateway identifier e.g. +:memory+
      #
      # @api public
      attr_reader :identifier

      # Returns the gateway class
      #
      # @api public
      attr_reader :gateway

      # Returns gateway's URI e.g. "super_db://something"
      #
      # @api public
      attr_reader :uri

      ROM::Lint::Gateway.each_lint do |name, linter|
        define_test_method name do
          assert linter.new(identifier, gateway, uri).lint(name)
        end
      end
    end

    # This is a simple lint-test for a gateway dataset class to ensure the
    # basic behavior is correct
    #
    # @example
    #
    #  class MyDatasetLintTest < Minitest::Test
    #    include ROM::Lint::TestEnumerableDataset
    #
    #     def setup
    #       @data  = [{ name: 'Jane', age: 24 }, { name: 'Joe', age: 25 }]
    #       @dataset = MyDataset.new(@data, [:name, :age])
    #     end
    #   end
    # @api public
    module TestEnumerableDataset
      extend ROM::Lint::Test

      # Returns the dataset instance
      #
      # @api public
      attr_reader :dataset

      # Returns the expected data
      #
      # @api public
      attr_reader :data

      ROM::Lint::EnumerableDataset.each_lint do |name, linter|
        define_test_method name do
          assert linter.new(dataset, data).lint(name)
        end
      end
    end
  end
end
