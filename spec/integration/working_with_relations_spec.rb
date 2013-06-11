require 'spec_helper'

describe 'Working with relations' do
  let(:mapper_class) { Mapper }
  let(:user_model)   { Class.new(OpenStruct) }

  specify 'relation setup' do
    pending 'in memory adapter is not finished yet'

    env  = ROM::Environment.coerce(:test => 'in_memory://test')
    repo = env.repository(:test)

    repo.register(:users, [[:id, Integer], [:name, String]], :keys => [:id])

    users    = repo.get(:users)
    mapper   = mapper_class.new(users)
    relation = ROM::Relation.new(users, mapper)

    user = user_model.new(id: 1, name: 'Jane')
    relation.insert(user)

    expect(relation.all).to include(user)
  end
end
