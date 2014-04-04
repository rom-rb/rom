require "spec_helper"

describe Mapper, "#join" do
  let(:task) { Mapper.build([[:title]], model: task_model) }
  let(:user) { Mapper.build([[:name]], model: user_model) }

  let(:task_model) { mock_model(:title) }
  let(:user_model) { mock_model(:name) }

  subject(:mapper) { task.join(user) }

  it "returns a mapper with joined headers" do
    expect(mapper).to eql(Mapper.build([[:title], [:name]], model: task_model))
  end
end
