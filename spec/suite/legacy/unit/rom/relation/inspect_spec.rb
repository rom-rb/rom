# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Memory::Relation, "#inspect" do
  subject(:relation) do
    Class.new(ROM::Relation[:memory]) do
      def self.name
        "Users"
      end
    end.new([], name: ROM::Relation::Name[:users])
  end

  specify do
    expect(relation.inspect).to eql(%(#<Users name=ROM::Relation::Name(users) dataset=[]>))
  end
end
