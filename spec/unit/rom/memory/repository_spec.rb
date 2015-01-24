require 'spec_helper'
require 'rom/lint/spec'
require 'rom/memory'

describe ROM::Memory::Repository do
  before do
    pending
    # FIXME: Remove when we get a way to control registration in specs
    ROM::Repository.registered.unshift(ROM::Memory::Repository)
  end

  let(:repository) { ROM::Memory::Repository }
  let(:uri) { "memory://localhost/test" }

  it_behaves_like "a rom repository"
end
