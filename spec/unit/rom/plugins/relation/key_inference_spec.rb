require 'rom'
require 'rom/memory'
require 'rom/plugins/relation/key_inference'

RSpec.describe ROM::Plugins::Relation::KeyInference do
  subject(:relation) { relation_class.new([]) }

  let(:relation_class) do
    Class.new(ROM::Memory::Relation) do
      use :key_inference

      dataset :users
    end
  end

  describe '#base_name' do
    it 'returns dataset name by default' do
      expect(relation.base_name).to be(:users)
    end
  end

  describe '#foreign_key' do
    it 'returns default value' do
      expect(relation.foreign_key).to be(:user_id)
    end
  end
end
