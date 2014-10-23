require "spec_helper"
require "rom/ra/operation/join"

describe RA::Operation::Join do
  subject(:join) { RA::Operation::Join.new(left, right) }

  let(:left) { Relation.new(DB[:users]) }
  let(:right) { [{ name: 'Jane', age: 21 }] }

  before do
    seed
  end

  after do
    deseed
  end

  describe '#each' do
    it 'yields joined relation' do
      result = []

      join.each do |user|
        result << user
      end

      expect(result).to eql([{ id: 1, name: 'Jane', age: 21 }])
    end
  end
end
