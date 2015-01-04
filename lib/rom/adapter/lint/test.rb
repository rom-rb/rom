module ROM
  class Adapter
    module Lint
      module Test
        attr_reader :adapter

        def test_schemes
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
          Adapter.setup("#{adapter.schemes.first}://localhost/test")
        end
      end
    end
  end
end
