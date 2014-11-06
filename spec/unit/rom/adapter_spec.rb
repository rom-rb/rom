require 'spec_helper'

class TestAdapter < Adapter
  def self.schemes
    [:test_scheme]
  end

  def initialize(uri); end

  Adapter.register(self)
end


describe Adapter do
  describe '.setup' do
    it 'sets up connection based on a uri' do
      adapter = Adapter.setup("test_scheme::memory")

      expect(adapter).to be_instance_of(TestAdapter)
    end

    it 'raises an exception if the scheme is not supported' do
      expect {
        Adapter.setup("bogus:///non-existent")
      }.to raise_error(ArgumentError, '"bogus:///non-existent" uri is not supported')
    end
  end

  describe '.[]' do
    it "looks up and return the adapter class for the given schema" do
      expect(Adapter[:test_scheme]).to eq TestAdapter
    end
  end


  describe 'Registration order' do
    it "prefers the last-defined adapter" do
      class OrderTestFirst < TestAdapter
        def self.schemes
          [:order_test]
        end
        Adapter.register(self)
      end
      adapter = Adapter.setup("order_test::memory")
      expect(adapter).to be_instance_of(OrderTestFirst)

      class OrderTestSecond < OrderTestFirst
        Adapter.register(self)
      end
      adapter = Adapter.setup("order_test::memory")
      expect(adapter).to be_instance_of(OrderTestSecond)


      Object.instance_eval { remove_const :OrderTestFirst }
      Object.instance_eval { remove_const :OrderTestSecond }

    end
  end

end
