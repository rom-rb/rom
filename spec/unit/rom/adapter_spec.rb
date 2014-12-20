require 'spec_helper'

describe ROM::Adapter do
  before do
    class TestAdapter < ROM::Adapter
      def self.schemes
        [:test_scheme]
      end

      def initialize(_uri); end

      ROM::Adapter.register(self)
    end
  end

  describe '.setup' do
    it 'sets up connection based on a uri' do
      adapter = ROM::Adapter.setup("test_scheme::memory")

      expect(adapter).to be_instance_of(TestAdapter)
    end

    it 'raises an exception if the scheme is not supported' do
      expect {
        ROM::Adapter.setup("bogus://any-host")
      }.to raise_error(ArgumentError, '"bogus://any-host" uri is not supported')
    end
  end

  describe '.[]' do
    it "looks up and return the adapter class for the given schema" do
      expect(ROM::Adapter[:test_scheme]).to eq TestAdapter
    end
  end

  describe 'Registration order' do
    it "prefers the last-defined adapter" do
      class OrderTestFirst < TestAdapter
        def self.schemes
          [:order_test]
        end

        ROM::Adapter.register(self)
      end

      adapter = ROM::Adapter.setup("order_test::memory")
      expect(adapter).to be_instance_of(OrderTestFirst)

      class OrderTestSecond < OrderTestFirst
        ROM::Adapter.register(self)
      end

      adapter = ROM::Adapter.setup("order_test::memory")

      expect(adapter).to be_instance_of(OrderTestSecond)
    end
  end
end
