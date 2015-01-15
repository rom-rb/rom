require 'spec_helper'
require 'rom/adapter/memory/storage'

describe ROM::Adapter::Memory::Storage do
  subject(:storage) do
    ROM::Adapter::Memory::Storage.new
  end

  describe 'thread safe' do
    let(:threads) { 4 }
    let(:operations) { 5000 }

    describe 'data' do
      it 'create datasets properly' do
        threaded_operations do |thread, operation|
          key = "#{thread}:#{operation}"
          storage.create_dataset(key)
        end

        expect(storage.size).to eql(threads * operations)
      end
    end

    describe 'dataset' do
      before { storage.create_dataset(:ary) }
      let(:dataset) { storage[:ary] }

      it 'inserts data in proper order' do
        threaded_operations do
          dataset << :data
        end

        expect(dataset.size).to eql(threads * operations)
      end
    end

    def threaded_operations
      threads.times.map do |thread|
        Thread.new do
          operations.times do |operation|
            yield thread, operation
          end
        end
      end.each(&:join)
    end
  end
end
