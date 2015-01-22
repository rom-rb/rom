require 'rom/lint/repository'
require 'rom/lint/enumerable_dataset'

RSpec.shared_examples "a rom repository" do
  ROM::Lint::Repository.each_lint do |name, linter|
    it name do
      result = linter.new(repository, uri).lint(name)
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
