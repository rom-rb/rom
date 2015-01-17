require 'spec_helper'

describe ROM::Repository do
  describe '.setup' do
    it 'sets up a repository based on a type' do
      repository_class = Class.new(ROM::Repository) do
        attr_reader :args
        def initialize(*args); @args = args; end
      end

      allow(ROM::Repository).to receive(:class_from_symbol)
        .with(:wormhole).and_return(repository_class)

      args = %w(hello world)
      repository = ROM::Repository.setup(:wormhole, *args)

      expect(repository).to be_instance_of(repository_class)
      expect(repository.args).to eq(args)
    end

    it 'raises an exception if the type is not supported' do
      expect {
        ROM::Repository.setup(:bogus, "memory://test")
      }.to raise_error(ArgumentError, ':bogus is not supported')
    end

    it 'accepts a repository instance' do
      repository = ROM::Repository.new
      expect(ROM::Repository.setup(repository)).to be(repository)
    end

    it 'raises an exception if instance and arguments are passed' do
      repository = ROM::Repository.new

      expect { ROM::Repository.setup(repository, 'foo://bar') }.to raise_error(
        ArgumentError,
        "Can't accept arguments when passing an instance"
      )
    end

    it 'raises an exception if a URI string is passed' do
      expect { ROM::Repository.setup('memory://test') }.to raise_error(
        ArgumentError,
        /URIs without an explicit scheme are not supported anymore/
      )
    end
  end

  describe '.class_from_symbol' do
    it 'instantiates a repository based on type' do
      klass = ROM::Repository.class_from_symbol(:memory)
      expect(klass).to be(ROM::Memory::Repository)
    end

    it 'raises an exception if the type is not supported' do
      expect { ROM::Repository.class_from_symbol(:bogus) }
        .to raise_error(ArgumentError, ':bogus is not supported')
    end
  end

  describe '#disconnect' do
    it 'does nothing' do
      repository_class = Class.new(ROM::Repository)
      repository = repository_class.new
      expect(repository.disconnect).to be(nil)
    end
  end
end
