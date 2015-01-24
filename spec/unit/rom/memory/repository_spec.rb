require 'spec_helper'
require 'rom/lint/spec'
require 'rom/memory'

describe ROM::Memory::Repository do
  let(:repository) { ROM::Memory::Repository }
  let(:uri) { nil }

  it_behaves_like "a rom repository" do
    let(:identifier) { :memory }
  end
end
