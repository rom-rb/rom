require 'rom/lint/gateway'
require 'rom/lint/enumerable_dataset'

RSpec.shared_examples "a rom repository" do
  before(:all) do
    ROM::Deprecations.announce "[Adapter]::Repository is", <<-MSG
      Please use [Adapter]::Gateway instead.
    MSG
  end

  let(:gateway) { repository }

  include_examples "a rom gateway"
end

RSpec.shared_examples "a rom gateway" do
  ROM::Lint::Gateway.each_lint do |name, linter|
    it name do
      result = linter.new(identifier, gateway, uri).lint(name)
      expect(result).to be_truthy
    end
  end
end

RSpec.shared_examples "a rom enumerable dataset" do
  ROM::Lint::EnumerableDataset.each_lint do |name, linter|
    it name do
      result = linter.new(dataset, data).lint(name)
      expect(result).to be_truthy
    end
  end
end
