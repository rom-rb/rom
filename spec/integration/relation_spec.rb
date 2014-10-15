require 'spec_helper'

require 'concord'
require 'sequel'

DB = Sequel.connect("sqlite::memory")

DB.run("CREATE TABLE users (id SERIAL, name STRING)")

describe Relation do
  subject(:relation) { Relation.new(DB[:users]) }

  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  before(:each) do
    DB[:users].insert(jane)
    DB[:users].insert(joe)
  end

  describe "#each" do
    it "yields all objects" do
      result = []

      relation.each do |user|
        result << user
      end

      expect(result).to eql([jane, joe])
    end
  end

end
