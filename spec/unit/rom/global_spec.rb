require 'spec_helper'

describe ROM do
  describe '.setup' do
    it 'allows passing in repository instances' do
      klass = Class.new(ROM::Repository)
      repo = klass.new

      setup = ROM.setup(test: repo)

      expect(setup.repositories[:test]).to be(repo)
    end
  end
end
