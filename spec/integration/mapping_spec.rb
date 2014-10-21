require 'spec_helper'
require 'ostruct'

describe Mapping do
  let(:relations) do
    { users: Relation.new([{ id: 231 }], Header.new(id: { type: Integer })) }
  end

  before do
    User = Class.new(OpenStruct)
  end

  after do
    Object.send(:remove_const, :User)
  end

  describe '.define' do
    it "returns mapper registry" do
      mappers = Mapping.define(relations) do
        relation(:users) do
          model User
          map :id
        end
      end

      expect(mappers.users.to_a).to eql([User.new(id: 231)])
    end
  end
end
