require 'spec_helper'

describe ROM::Commands::Result do
  describe ".wrap" do
    context ROM::Commands::Result::Success do
      it "wraps unwrapped values in success" do
        value = double(:value)
        wrapped = described_class.wrap(value)
        expect(wrapped).to be_a described_class
        expect(wrapped.value).to eq(value)
      end

      it "leaves wrapped values alone" do
        value = ROM::Commands::Result::Failure.new("Failure to launch")
        expect(described_class.wrap(value)).to eq(value)
      end
    end

    context ROM::Commands::Result::Failure do
      it "wraps unwrapped values in failure" do
        value = double(:value)
        wrapped = described_class.wrap(value)
        expect(wrapped).to be_a described_class
        expect(wrapped.error).to eq(value)
      end

      it "leaves wrapped values alone" do
        value = ROM::Commands::Result::Success.new("We did it!")
        expect(described_class.wrap(value)).to eq(value)
      end
    end
  end

  describe '#value' do
    subject(:result) { ROM::Commands::Result::Success }

    it 'bubble up nested values' do
      data = double(to_ary: ['foo'])
      r = result.new(result.new(result.new(data)))

      expect(r.value).to eq(data)
    end
  end
end
