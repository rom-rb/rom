require 'spec_helper'

describe 'Reusing mappers' do
  it 'allows using another mapper in mapping definitions' do
    class Test::TaskMapper < ROM::Mapper
      attribute :title
    end

    class Test::UserMapper < ROM::Mapper
      attribute :name
      group :tasks, mapper: Test::TaskMapper
    end

    mapper = Test::UserMapper.build
    relation = [{ name: 'Jane', title: 'One' }, { name: 'Jane', title: 'Two' }]
    result = mapper.call(relation)

    expect(result).to eql([
      { name: 'Jane', tasks: [{ title: 'One' }, { title: 'Two' }] }
    ])
  end
end
