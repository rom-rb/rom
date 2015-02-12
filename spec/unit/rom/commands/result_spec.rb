require 'spec_helper'

describe ROM::Commands::Result do
  describe ".success" do
    subject(:result) { ROM::Commands::Result.success(value) }

    let(:value) { double(:value) }

    it "wraps the value in a success" do
      expect(result).to be_a(ROM::Commands::Result::Success)
      expect(result.value).to eq(value)
    end
  end

  describe ".failure" do
    subject(:result) { ROM::Commands::Result.failure(error) }

    let(:error) { double(:error) }

    it "wraps the value in a failure" do
      expect(result).to be_a(ROM::Commands::Result::Failure)
      expect(result.error).to eq(error)
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
