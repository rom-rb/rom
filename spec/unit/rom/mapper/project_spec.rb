require "spec_helper"

describe Mapper, "#project" do
  let(:task) { Mapper.build([[:id], [:name]]) }

  subject(:mapper) { task.project([:id]) }

  it "returns a mapper with a projected header" do
    expect(mapper).to eql(Mapper.build([[:id]]))
  end
end
