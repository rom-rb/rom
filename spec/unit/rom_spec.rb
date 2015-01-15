require 'spec_helper'
require 'rom/adapter/memory'

describe ROM do
  describe '.setup' do
    it 'creates a boot instance using a database config hash' do
      boot = ROM.setup(
        adapter: 'memory', database: 'test', hostname: 'localhost'
      )

      expect(boot[:default]).to be(boot.repositories[:default])
      expect(boot.default.uri.to_s).to eql("memory://localhost/test")
    end
  end
end
