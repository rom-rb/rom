require 'spec_helper'

describe ROM::Repository do

  it "warns when inherited from" do
    expect {
      Class.new(ROM::Repository)
    }.to output(/inherit from ROM::Gateway/).to_stderr
  end


end
