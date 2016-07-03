require 'rom'
require 'rom/memory'
require 'rom/plugins/relation/key_inference'

RSpec.describe ROM::Plugins::Relation::KeyInference do
  subject(:relation) do
    relation_class.new([], __registry__: { posts: posts, users: users, tags: tags })
  end

  let(:posts) { double(foreign_key: :post_id) }
  let(:tags) { double(foreign_key: :tag_id) }
  let(:users) { double(base_name: ROM::Relation::Name[:users]) }

  describe 'without a schema' do
    let(:relation_class) do
      Class.new(ROM::Memory::Relation) do
        use :key_inference

        dataset :users
      end
    end

    describe '#base_name' do
      it 'returns dataset name by default' do
        expect(relation.base_name).to eql(ROM::Relation::Name[:users])
      end
    end

    describe '#foreign_key' do
      it 'returns default value' do
        expect(relation.foreign_key).to be(:user_id)
      end

      it 'returns default value for another relation' do
        expect(relation.foreign_key(:posts)).to be(:post_id)
        expect(relation.foreign_key(posts)).to be(:post_id)
      end
    end
  end

  describe 'with a schema' do
    let(:relation_class) do
      Class.new(ROM::Memory::Relation) do
        use :key_inference

        schema :posts do
          attribute :author_id, ROM::Types::Int.meta(foreign_key: true, relation: :users)
        end
      end
    end

    describe '#foreign_key' do
      it 'returns configured value' do
        expect(relation.foreign_key(:users)).to be(:author_id)
        expect(relation.foreign_key(users)).to be(:author_id)
      end

      it 'falls back to default when schema has no fk specified' do
        expect(relation.foreign_key(:tags)).to be(:tag_id)
      end
    end
  end
end
