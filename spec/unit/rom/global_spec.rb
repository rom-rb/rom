require 'spec_helper'

describe ROM do
  describe '.setup' do
    it 'allows passing in gateway instances' do
      klass = Class.new(ROM::Gateway)
      repo = klass.new

      setup = ROM.setup(test: repo)

      expect(setup.gateways[:test]).to be(repo)
    end
  end

end
