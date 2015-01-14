module ROM
  class Adapter
    module Lint
      module CommonAdapter
        class << self
          attr_accessor :tests
        end
        self.tests = []

        def self.test(name, &block)
          tests << [name, block]
        end

        def self.each(&block)
          tests.each(&block)
        end

        test "schemes" do
          assert_respond_to adapter, :schemes,
            "#{adapter}.schemes must be implemented"

          assert_instance_of Array, adapter.schemes,
            "#{adapter}.schemes must return an array with supported URI schemes"

          assert adapter.schemes.any?,
            "#{adapter}.schemes must return at least one supported URI scheme"
        end

        test "setup" do
          assert_instance_of adapter, adapter_instance
        end

        test "dataset reader" do
          assert_respond_to adapter_instance, :[]
        end

        test "dataset predicate" do
          assert_respond_to adapter_instance, :dataset?
        end
      end

      module CommonEnumerableDataset
        class << self
          attr_accessor :tests
        end
        self.tests = []

        def self.test(name, &block)
          tests << [name, block]
        end

        def self.each(&block)
          tests.each(&block)
        end

        test "each" do
          result = []
          dataset.each { |tuple| result << tuple }
          assert_equal result, data,
            "#{dataset.class}#each must yield tuples"
        end

        test "to_a" do
          assert_equal dataset.to_a, data,
            "#{dataset.class}#to_a must cast dataset to an array"
        end
      end
    end
  end
end
