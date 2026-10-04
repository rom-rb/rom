# frozen_string_literal: true

require 'rom/cache'

RSpec.describe ROM::Cache do
  subject(:cache) { ROM::Cache.new }

  describe '.key' do
    it 'returns the same key for equal objects' do
      expect(ROM::Cache.key([:users, { name: 'Jane', tags: [:a] }]))
        .to eql(ROM::Cache.key([:users, { name: 'Jane', tags: [:a] }]))
    end

    # On JRuby, Hash#hash often returns the same value for hashes that differ only in a module or
    # class value (such as relation AST meta with different struct namespaces). Stub Hash#hash to
    # force that collision here.
    it 'returns different keys for different hashes with the same Hash#hash' do
      hash_a, hash_b = [{ struct_namespace: Module.new }, { struct_namespace: Module.new }].each do |hash|
        def hash.hash = 1
      end

      expect(ROM::Cache.key([:users, hash_a])).not_to eql(ROM::Cache.key([:users, hash_b]))
    end

    it 'returns different keys for a hash and an array of its pairs' do
      expect(ROM::Cache.key({ a: 1 })).not_to eql(ROM::Cache.key([[:a, 1]]))
    end
  end

  describe '#fetch_or_store' do
    it 'returns existing object' do
      obj = 'foo'

      expect(cache.fetch_or_store(obj) { obj })
      expect(cache.fetch_or_store(obj)).to be(obj)
    end
  end

  describe '#namespaced' do
    it 'returns a namespaced cache' do
      namespaced = cache.namespaced(:foo)

      expect(namespaced).to be_instance_of(ROM::Cache::Namespaced)
      expect(namespaced).to be(cache.namespaced(:foo))
    end
  end

  context 'namespace cache' do
    describe '#fetch_or_store' do
      it 'returns existing object' do
        namespaced = cache.namespaced('stuff')
        obj = 'foo'

        expect(namespaced.fetch_or_store(obj) { obj })
        expect(namespaced.fetch_or_store(obj)).to be(obj)
      end
    end
  end
end
