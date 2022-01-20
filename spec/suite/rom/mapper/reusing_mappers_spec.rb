# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Reusing mappers" do
  it "allows using another mapper in mapping definitions" do
    class Test::TaskMapper < ROM::Mapper
      attribute :title
    end

    class Test::UserMapper < ROM::Mapper
      attribute :name
      group :tasks, mapper: Test::TaskMapper
    end

    mapper = Test::UserMapper.build
    relation = [{name: "Jane", title: "One"}, {name: "Jane", title: "Two"}]
    result = mapper.call(relation)

    expect(result).to eql([
      {name: "Jane", tasks: [{title: "One"}, {title: "Two"}]}
    ])
  end

  it "allows using another mapper in an embbedded hash" do
    class Test::PriorityMapper < ROM::Mapper
      attribute :value, type: :integer
      attribute :desc
    end

    class Test::TaskMapper < ROM::Mapper
      attribute :title
      embedded :priority, type: :hash, mapper: Test::PriorityMapper
    end

    mapper = Test::TaskMapper.build
    relation = [{title: "Task One", priority: {value: "1"}}, {title: "Task Two", priority: {value: "2"}}]
    result = mapper.call(relation)

    expect(result).to eql([
      {title: "Task One", priority: {value: 1}},
      {title: "Task Two", priority: {value: 2}}
    ])
  end
end
