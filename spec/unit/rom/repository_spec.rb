require 'spec_helper'

describe ROM::Repository do
  before do
    class TestRepository < ROM::Repository
      def self.schemes
        [:test_scheme]
      end
    end
  end

  describe '.setup' do
    it 'sets up connection based on a uri' do
      repository = ROM::Repository.setup("test_scheme::memory")

      expect(repository).to be_instance_of(TestRepository)
    end

    it 'raises an exception if the scheme is not supported' do
      expect {
        ROM::Repository.setup("bogus://any-host")
      }.to raise_error(ArgumentError, '"bogus://any-host" uri is not supported')
    end
  end

  describe '.[]' do
    it "looks up and return the repository class for the given schema" do
      expect(ROM::Repository[:test_scheme]).to eq TestRepository
    end
  end

  describe 'Registration order' do
    it "prefers the last-defined repository" do
      class OrderTestFirst < TestRepository
        def self.schemes
          [:order_test]
        end
      end

      repository = ROM::Repository.setup("order_test::memory")
      expect(repository).to be_instance_of(OrderTestFirst)

      OrderTestSecond = Class.new(OrderTestFirst)

      repository = ROM::Repository.setup("order_test::memory")

      expect(repository).to be_instance_of(OrderTestSecond)
    end
  end

  describe '#disconnect' do
    it 'does nothing' do
      repository_class = Class.new(ROM::Repository) {
        def self.schemes
          [:bazinga]
        end
      }

      repository = repository_class.new('bazinga://localhost')

      expect(repository.disconnect).to be(nil)
    end
  end

  describe '.setup' do
    it 'supports connection uri and additional options' do
      Class.new(ROM::Repository) {
        def self.schemes
          [:bazinga]
        end
      }

      repository = ROM::Repository.setup('bazinga://localhost', super: :option)

      expect(repository.uri).to eql(Addressable::URI.parse('bazinga://localhost'))
      expect(repository.options).to eql(super: :option)
    end
  end
end
