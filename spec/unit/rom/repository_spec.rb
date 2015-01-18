require 'spec_helper'

describe ROM::Repository do
  let(:test_repository) do
    Class.new(ROM::Repository) do
      def self.schemes
        [:test_scheme]
      end
    end
  end

  describe '.setup' do
    before { test_repository }

    it 'sets up a repository based on a scheme' do
      repository = ROM::Repository.setup(:test_scheme, 'some::memory')

      expect(repository).to be_instance_of(test_repository)
    end

    it 'raises an exception if the scheme is not supported' do
      expect {
        ROM::Repository.setup(:bogus, "memory://test")
      }.to raise_error(ArgumentError, ':bogus scheme is not supported')
    end

    it 'raises an exception if scheme is not passed explicitely' do
      expect { ROM::Repository.setup('memory://test') }.to raise_error(
        ArgumentError,
        /URIs without an explicit scheme are not supported anymore/
      )
    end

    it 'supports connection uri and additional options' do
      uri = Addressable::URI.parse('foo://localhost')

      Class.new(ROM::Repository) {
        def self.schemes
          [:bazinga]
        end
      }

      repository = ROM::Repository.setup(:bazinga, uri.to_s, super: :option)

      expect(repository.uri).to eql(uri)
      expect(repository.options).to eql(super: :option)
    end
  end

  describe '.[]' do
    it "looks up and return the repository class for the given schema" do
      test_repository

      expect(ROM::Repository[:test_scheme]).to eq test_repository
    end

    it "returns nil w/o registered repositories" do
      expect(ROM::Repository[:test_scheme]).to eq nil
    end
  end

  describe 'Registration order' do
    it "prefers the last-defined repository" do
      order_test_first = Class.new(test_repository) do
        def self.schemes
          [:order_test]
        end
      end

      repository = ROM::Repository.setup(:order_test, 'order_test::memory')
      expect(repository).to be_instance_of(order_test_first)

      order_test_second = Class.new(order_test_first)

      repository = ROM::Repository.setup(:order_test, 'order_test::memory')

      expect(repository).to be_instance_of(order_test_second)
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
end
