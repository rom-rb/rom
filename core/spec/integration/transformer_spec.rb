require 'rom'
require 'rom/transformer'

RSpec.describe ROM::Transformer do
  subject(:mapper) do
    rom.mappers[:users][:default]
  end

  let(:relation) do
    rom.relations[:users]
  end

  let(:rom) do
    ROM.container(:memory) do |config|
      config.relation(:users)

      config.register_mapper(mapper_class)
    end
  end

  let(:mapper_class) do
    Class.new(ROM::Transformer) do
      relation :users, as: :default

      map do
        rename_keys user_id: :id
      end
    end
  end

  it 'works with rom container' do
    relation.insert(user_id: 1, name: 'Jane')

    expect(relation.map_with(:default).to_a).to include(id: 1, name: 'Jane')
  end
end
