# encoding: utf-8

require 'spec_helper'

describe Session::Relation, '#one' do
  include_context 'Session::Relation'

  it "returns first object and starts tracking" do
    jane = users.restrict(name: "Jane").one

    expect(users.tracking?(jane)).to be(true)
  end
end
