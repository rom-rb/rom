require 'spec_helper'

describe ROM::Commands::Result do
  describe "control flow" do
    let(:blk_result) { double(:blk_result) }
    let(:blk) { ->(_) { blk_result } }
    let(:wrapped_blk_result) { double(:wrapped_blk_result) }

    before do
      allow(ROM::Commands::Result).to receive(:wrap)
      allow(ROM::Commands::Result).to receive(:wrap).
        with(blk_result).and_return(wrapped_blk_result)
    end

    context ROM::Commands::Result::Success do
      subject(:result) { described_class.new(value) }

      let(:value) { double(:value) }

      describe '#and_then' do
        it 'calls the block with the value of the result' do
          expect { |blk|
            result.and_then(&blk)
          }.to yield_with_args(value)
        end

        it 'wraps the return value of the block in a result' do
          expect(result.and_then(&blk)).to eq(wrapped_blk_result)
        end
      end

      describe '#or_else' do
        it 'does not call the block' do
          expect { |blk|
            result.or_else(&blk)
          }.not_to yield_control
        end

        it 'returns the result' do
          expect(result.or_else(&blk)).to eq(result)
        end
      end
    end

    context ROM::Commands::Result::Failure do
      subject(:result) { described_class.new(error) }

      let(:error) { double(:error) }

      describe '#and_then' do
        it 'does not call the block' do
          expect { |blk|
            result.and_then(&blk)
          }.not_to yield_control
        end

        it 'returns the result' do
          expect(result.and_then(&blk)).to eq(result)
        end
      end

      describe '#or_else' do
        it 'calls the block with the error of the result' do
          expect { |blk|
            result.or_else(&blk)
          }.to yield_with_args(error)
        end

        it 'wraps the return value of the block in a result' do
          expect(result.or_else(&blk)).to eq(wrapped_blk_result)
        end
      end
    end
  end
end
