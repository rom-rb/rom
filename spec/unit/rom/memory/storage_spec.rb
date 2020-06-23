# frozen_string_literal: true

require "spec_helper"
require "rom/memory/storage"

RSpec.describe ROM::Memory::Storage do
  describe "thread safe" do
    let(:threads) { 4 }
    let(:operations) { 5000 }

    describe "data" do
      it "create datasets properly" do
        storage = ROM::Memory::Storage.new

        threaded_operations do |thread, operation|
          key = "#{thread}:#{operation}"
          storage.create_dataset(key)
        end

        expect(storage.size).to eql(threads * operations)
      end
    end

    describe "dataset" do
      it "inserts data in proper order" do
        storage = ROM::Memory::Storage.new
        dataset = storage.create_dataset(:ary)

        threaded_operations do
          dataset << :data
        end

        expect(dataset.size).to eql(threads * operations)
      end
    end

    def threaded_operations
      threads.times.map { |thread|
        Thread.new do
          operations.times do |operation|
            yield thread, operation
          end
        end
      }.each(&:join)
    end
  end
end
