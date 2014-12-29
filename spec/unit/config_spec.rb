require 'spec_helper'

describe ROM::Config do
  describe '.build' do
    let(:raw_config) do
      { adapter: 'memory', hostname: 'localhost', database: 'test', port: 312 }
    end

    it 'returns rom repository configuration hash' do
      config = ROM::Config.build(raw_config)

      expect(config).to eql(default: 'memory://localhost/test:312')
    end

    it 'sets additional options' do
      config = ROM::Config.build(raw_config.update(super: :option, root: '/somewhere'))

      expect(config).to eql(
        default: { uri: 'memory://localhost/test:312', options: { super: :option } }
      )

      config = ROM::Config.build('memory://localhost/test', super: :option)

      expect(config).to eql(
        default: { uri: 'memory://localhost/test', options: { super: :option } }
      )
    end

    it 'builds absolute path to the database file when database is a file' do
      expect(ROM::Adapter[:memory]).to receive(:database_file?)
        .with('memory').and_return(true)

      config = ROM::Config.build(
        adapter: 'memory', database: 'test', root: '/somewhere'
      )

      expect(config).to eql(default: 'memory:///somewhere/test')
    end

    it 'turns a uri into configuration hash' do
      config = ROM::Config.build('test://localhost/rom')
      expect(config).to eql(default: 'test://localhost/rom')
    end

    it 'returns original config hash if it is already in rom format' do
      config = ROM::Config.build(test: 'test://localhost/rom')
      expect(config).to eql(test: 'test://localhost/rom')
    end

    it 'asks adapters to normalize scheme' do
      expect(ROM::Adapter[:memory]).to receive(:normalize_scheme).with('memory')
      ROM::Config.build(raw_config)
    end
  end
end
