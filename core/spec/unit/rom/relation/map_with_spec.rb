require 'rom/relation'

RSpec.describe ROM::Relation, '#map_with' do
  subject(:relation) do
    ROM::Relation.new(
      dataset,
      name: ROM::Relation::Name[:users],
      schema: schema,
      mappers: mapper_registry
    )
  end

  let(:mapper_registry) { ROM::MapperRegistry.build(mappers) }

  let(:dataset) do
    [{ id: 1, name: 'Jane' }, {id: 2, name: 'Joe' }]
  end

  context 'without the default mapper' do
    let(:schema) do
      define_schema(:users, id: :Integer, name: :String)
    end

    let(:mappers) do
      {
        name_list: -> users { users.map { |u| u[:name] } },
        upcase_names: -> names { names.map(&:upcase) },
        identity: -> users { users }
      }
    end

    it 'sends the relation through custom mappers' do
      expect(relation.map_with(:name_list, :upcase_names).to_a).to match_array(%w(JANE JOE))
    end

    it 'does not use the default mapper' do
      expect(relation.map_with(:identity).to_a).to eql(dataset)
    end
  end

  context 'with the default mapper' do
    let(:schema) do
      define_schema(:users, id: :Integer, name: :String).prefix(:user)
    end

    let(:mappers) do
      { name_list: -> users { users.map { |u| u[:user_name] } } }
    end

    it 'sends the relation through custom mappers' do
      expect(relation.map_with(:name_list).to_a).to match_array(%w(Jane Joe))
    end
  end
end
