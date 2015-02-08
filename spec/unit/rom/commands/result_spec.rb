require 'spec_helper'

describe ROM::Commands::Result do
  describe '#value' do
    subject(:result) { ROM::Commands::Result::Success }

    it 'bubble up nested values' do
      data = double(to_ary: ['foo'])
      r = result.new(result.new(result.new(data)))

      expect(r.value).to eq(data)
    end
  end
end
