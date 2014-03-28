require "spec_helper"

describe Mapper, "#wrap" do
  let(:task) { Mapper.build([[:title]], model: task_model) }
  let(:user) { Mapper.build([[:id], [:name]], model: user_model) }

  let(:task_model) { mock_model(:title, :user) }
  let(:user_model) { mock_model(:id, :name) }

  subject(:mapper) { task.wrap(user: user) }

  let(:loader_transformer) do
    Morpher.compile(
      s(:block,
        s(:hash_transform,
          s(:block, s(:key_fetch, :title), s(:key_dump, :title)),
          s(:key_transform, :user, :user, user.loader.node)
         ),
        s(:load_instance_variables, s(:param, task_model, :title, :user))
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
