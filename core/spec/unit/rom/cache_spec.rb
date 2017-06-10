require 'rom/cache'

RSpec.describe ROM::Cache do
  subject(:cache) { ROM::Cache.new }

  describe '#fetch_or_store' do
    it 'returns existing object' do
      obj = 'foo'

      expect(cache.fetch_or_store(obj) { obj })
      expect(cache.fetch_or_store(obj)).to be(obj)
    end
  end
end
