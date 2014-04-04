require "spec_helper"

describe Mapper, "#project" do
  let(:task) { Mapper.build([[:id, from: :user_id], [:name]]) }

  subject(:mapper) { task.project([:user_id]) }

  it "returns a mapper with a projected header" do
    expect(mapper).to eql(Mapper.build([[:id, from: :user_id]]))
  end
end
