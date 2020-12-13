# frozen_string_literal: true

require "rom"

RSpec.describe ROM::Repository, "#inspect" do
  subject(:repo) do
    Class.new(ROM::Repository) do
      def self.to_s
        "UserRepo"
      end
    end.new(rom)
  end

  include_context "repository / database"
  include_context "relations"

  specify do
    expect(repo.inspect).to eql("#<UserRepo struct_namespace=ROM::Struct auto_struct=true>")
  end
end
