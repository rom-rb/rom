require 'spec_helper'

require 'ostruct'

describe ROM::Mapper do
  subject(:mapper) { ROM::Mapper.new(ROM::Header.coerce(relation.header.zip), user_model) }

  let(:relation) { ROM::Relation.new(DB[:users]) }
  let(:user_model) { Class.new(OpenStruct) { include Equalizer.new(:id, :name) } }

  let(:jane) { user_model.new(id: 1, name: 'Jane') }
  let(:joe) { user_model.new(id: 2, name: 'Joe') }

  before do
    seed
  end

  after do
    deseed
  end

  describe "#each" do
    it "yields all mapped objects" do
      result = []

      relation.each do |tuple|
        result << mapper.load(tuple)
      end

      expect(result).to eql([jane, joe])
    end
  end

end
