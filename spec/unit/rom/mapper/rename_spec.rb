# encoding: utf-8

require 'spec_helper'

describe Mapper, '#rename' do
  include_context 'Mapper'

  let(:model) { mock_model(:user_id, :user_name) }

  it 'renames attributes' do
    tuple = { :user_id => 1, :user_name => 'Jane' }
    user = model.new(:user_id => 1, :user_name => 'Jane')

    expect(mapper.rename(:id => :user_id, :name => :user_name).load(tuple)).to eql(user)
  end
end
