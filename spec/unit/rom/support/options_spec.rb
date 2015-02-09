require 'spec_helper'

describe ROM::Options do
  let(:klass) do
    Class.new do
      include ROM::Options

      option :name, type: String, reader: true, allow: %w(foo bar)
      option :repo, reader: true
      option :other
    end
  end

  describe '.new' do
    it 'sets options hash' do
      object = klass.new(name: 'foo')
      expect(object.options).to eql(name: 'foo')
    end

    it 'allows any value when :allow is not specified' do
      repo = double('repo')
      object = klass.new(repo: repo)
      expect(object.options).to eql(repo: repo)
    end

    it 'sets readers for options when specified' do
      object = klass.new(name: 'bar', repo: 'default')
      expect(object.name).to eql('bar')
      expect(object.repo).to eql('default')
      expect(object).to_not respond_to(:other)
    end

    it 'checks option key' do
      expect { klass.new(unexpected: 'foo') }
        .to raise_error(ROM::InvalidOptionKeyError, /:unexpected/)
    end

    it 'checks option type' do
      expect { klass.new(name: :foo) }
        .to raise_error(ROM::InvalidOptionValueError, /:foo/)
    end

    it 'checks option value' do
      expect { klass.new(name: 'invalid') }
        .to raise_error(ROM::InvalidOptionValueError, /invalid/)
    end

    it 'copies klass options to descendant' do
      other = Class.new(klass).new(name: 'foo')
      expect(other.options).to eql(name: 'foo')
    end

    it 'does not interfere with its parent`s option definitions' do
      other = Class.new(klass) do
        option :child, default: :nope
      end
      object = klass.new({})
      expect(object.options).to eql({})
    end

    it 'sets option defaults statically' do
      default_value = []
      klass.option :args, default: default_value

      object = klass.new({})

      expect(object.options).to eql(args: default_value)
      expect(object.options[:args]).to equal(default_value)
    end

    it 'sets option defaults dynamically via proc' do
      klass.option :args, default: proc { |*a| a }

      object = klass.new({})

      expect(object.options).to eql(args: [object])
    end

    it 'allow nil as default value' do
      klass.option :args, default: nil

      object = klass.new({})

      expect(object.options).to eql(args: nil)
    end
  end
end
