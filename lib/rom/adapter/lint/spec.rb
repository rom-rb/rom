require 'rom/adapter/lint/common'
require 'rspec'

module ROM
  class Adapter
    module Lint
      module Spec
        RSpec.shared_examples "adapter" do
          CommonAdapter.each do |name, block|
            specify name, &block
          end
        end

        RSpec.shared_examples "enumerable dataset" do
          CommonEnumerableDataset.each do |name, block|
            specify name, &block
          end
        end
      end
    end
  end
end
