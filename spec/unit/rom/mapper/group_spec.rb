require "spec_helper"

describe Mapper, "#group" do
  subject(:mapper) { user.group(tasks: task) }

  let(:user) { Mapper.build([[:name]], model: user_model) }
  let(:task) { Mapper.build([[:title]], model: task_model) }

  let(:user_model) { mock_model(:name, :tasks) }
  let(:task_model) { mock_model(:title) }

  let(:loader_transformer) do
    Morpher.compile(
      s(:block,
        s(:hash_transform,
          s(:block, s(:key_fetch, :name), s(:key_dump, :name)),
          s(:key_transform, :tasks, :tasks, s(:map, task.loader.node))
         ),
        s(:load_instance_variables, s(:param, user_model, :name, :tasks))
       )
    )
  end

  let(:dumper_transformer) do
    loader_transformer.inverse
  end

  it "returns a mapper that can load wrapped tuples" do
    expect(mapper.loader).to eq(loader_transformer)
  end

  it "returns a mapper that can dump wrapped objects" do
    expect(mapper.dumper).to eq(dumper_transformer)
  end
end
