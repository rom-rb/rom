# frozen_string_literal: true

RSpec.describe ROM::Relation::Combined do
  subject(:relation) do
    ROM::Relation::Combined.new(users, [tasks])
  end

  let(:users) do
    Class.new(ROM::Relation) do
      auto_map false
    end.new([])
  end

  let(:tasks) do
    Class.new(ROM::Relation) do
      auto_map false

      def call(_users)
        ROM::Relation::Loaded.new(self)
      end
    end.new([])
  end

  describe "#call" do
    it "materializes relations" do
      result = relation.call

      expect(result).to be_instance_of(ROM::Relation::Loaded)
      expect(result.source).to be(relation)
    end
  end
end
