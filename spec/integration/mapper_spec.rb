require 'spec_helper'

require 'ostruct'

describe Mapper do
  subject(:mapper) { Mapper.new(relation, user_model) }

  let(:relation) { Relation.new(DB[:users]) }
  let(:user_model) { Class.new(OpenStruct) { include Equalizer.new(:id, :name) } }

  let(:jane) { user_model.new(id: 1, name: 'Jane') }
  let(:joe) { user_model.new(id: 2, name: 'Joe') }

  describe "#each" do
    it "yields all mapped objects" do
      result = []

      mapper.each do |user|
        result << user
      end

      expect(result).to eql([jane, joe])
    end
  end

end
