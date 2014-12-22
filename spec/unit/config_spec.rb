require 'spec_helper'

describe ROM::Config do
  describe '.build' do
    let(:raw_config) do
      { adapter: 'memory', hostname: 'localhost', database: 'test' }
    end

    it 'returns rom repository configuration hash' do
      config = ROM::Config.build(raw_config)

      expect(config).to eql(default: 'memory://localhost/test')
    end

    it 'builds absolute path to the database file when root is provided' do
      config = ROM::Config.build(
        adapter: 'memory', database: 'test', root: '/somewhere'
      )

      expect(config).to eql(default: 'memory:///somewhere/test')
    end

    it 'turns a uri into configuration hash' do
      config = ROM::Config.build('test://localhost/rom')
      expect(config).to eql(default: 'test://localhost/rom')
    end

    it 'asks adapters to normalize scheme' do
      expect(ROM::Adapter[:memory]).to receive(:normalize_scheme).with('memory')
      ROM::Config.build(raw_config)
    end
  end
end
