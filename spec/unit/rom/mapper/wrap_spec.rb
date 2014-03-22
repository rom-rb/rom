require "spec_helper"

describe ROM::Mapper, "#wrap" do
  let(:task) { ROM::Mapper.build([[:title]], task_model) }
  let(:user) { ROM::Mapper.build([[:id], [:name]], user_model) }

  let(:task_model) { mock_model(:title, :user) }
  let(:user_model) { mock_model(:id, :name) }

  subject(:mapper) { task.wrap(user: user) }

  let(:loader_transformer) do
    Morpher.compile(
      s(:block,
        s(:hash_transform,
          s(:block, s(:key_fetch, :title), s(:key_dump, :title)),
          s(:key_transform, :user, :user, user.loader.transformer.node)
         ),
        s(:load_instance_variables, s(:param, task_model, :title, :user))
       )
    )
  end

  let(:dumper_transformer) do
    loader_transformer.inverse
  end

  it "returns a mapper that can load wrapped tuples" do
    expect(mapper.loader.transformer.node).to eq(loader_transformer.node)
  end

  it "returns a mapper that can dump wrapped objects" do
    expect(mapper.dumper.transformer).to eq(dumper_transformer)
  end
end
