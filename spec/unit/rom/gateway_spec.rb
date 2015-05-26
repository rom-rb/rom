require 'spec_helper'

describe ROM::Gateway do
  describe '.setup' do
    it 'sets up a repository based on a type' do
      repository_class = Class.new(ROM::Gateway) do
        attr_reader :args

        def initialize(*args)
          @args = args
        end
      end

      allow(ROM::Gateway).to receive(:class_from_symbol)
        .with(:wormhole).and_return(repository_class)

      args = %w(hello world)
      repository = ROM::Gateway.setup(:wormhole, *args)

      expect(repository).to be_instance_of(repository_class)
      expect(repository.args).to eq(args)
    end

    it 'raises an exception if the type is not supported' do
      expect {
        ROM::Gateway.setup(:bogus, "memory://test")
      }.to raise_error(ROM::AdapterLoadError, /bogus/)
    end

    it 'accepts a repository instance' do
      repository = ROM::Gateway.new
      expect(ROM::Gateway.setup(repository)).to be(repository)
    end

    it 'raises an exception if instance and arguments are passed' do
      repository = ROM::Gateway.new

      expect { ROM::Gateway.setup(repository, 'foo://bar') }.to raise_error(
        ArgumentError,
        "Can't accept arguments when passing an instance"
      )
    end

    it 'raises an exception if a URI string is passed' do
      expect { ROM::Gateway.setup('memory://test') }.to raise_error(
        ArgumentError,
        /URIs without an explicit scheme are not supported anymore/
      )
    end
  end

  describe '.class_from_symbol' do
    it 'instantiates a repository based on type' do
      klass = ROM::Gateway.class_from_symbol(:memory)
      expect(klass).to be(ROM::Memory::Repository)
    end

    it 'raises an exception if the type is not supported' do
      expect { ROM::Gateway.class_from_symbol(:bogus) }
        .to raise_error(ROM::AdapterLoadError, /bogus/)
    end
  end

  describe '#disconnect' do
    it 'does nothing' do
      repository_class = Class.new(ROM::Gateway)
      repository = repository_class.new
      expect(repository.disconnect).to be(nil)
    end
  end
end
