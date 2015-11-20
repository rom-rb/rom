require 'spec_helper'

describe ROM do
  include_context 'container'

  describe '.env' do
    it 'is nil by default' do
      container

      expect(ROM.env).to be(nil)
    end

    it 'is assignable' do
      ROM.env = container
      expect(ROM.env).to be(container)
    end
  end
end
