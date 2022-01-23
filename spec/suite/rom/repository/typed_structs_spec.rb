# frozen_string_literal: true

require "rom/repository"

RSpec.describe "ROM repository with typed structs" do
  subject(:repo) do
    Class.new(ROM::Repository[:books]) { commands :create }.new(rom)
  end

  include_context "repository / database"
  include_context "seeds"

  context "typed projections" do
    before do
      pending "TODO: rework `view` DSL"

      configuration.relation(:books) do
        schema(:books, infer: true)

        view(:index) do
          schema do
            project(:id, :title, :created_at)
          end

          relation do
            order(:title)
          end
        end
      end

      rom.relations[:books].insert(title: "Hello World", created_at: Time.now)
    end

    it "loads typed structs" do
      book = repo.books.index.first

      expect(book).to be_kind_of(Dry::Struct)

      expect(book.id).to be_kind_of(Integer)
      expect(book.title).to eql("Hello World")
      expect(book.created_at).to be_kind_of(Time)
    end
  end

  context "read-write type coercions" do
    before do
      configuration.relation(:books) do
        schema(:books, infer: true) do
          attribute :title,
                    ROM::Types::Coercible::String.meta(
                      read: ROM::Types::Symbol.constructor { |s| (s + "!").to_sym }
                    )
        end
      end

      configuration.commands(:books) do
        define(:create) { config.result = :one }
      end
    end

    # FIXME: this is flaky
    it "loads typed structs" do
      created_book = repo.create(title: :'Hello World', created_at: Time.now)

      expect(created_book).to be_kind_of(Dry::Struct)

      expect(created_book.id).to be_kind_of(Integer)
      expect(created_book.title).to eql(:'Hello World!')
      expect(created_book.created_at).to be_kind_of(Time)

      book = repo.books.to_a.first

      expect(book).to eql(created_book)
    end
  end
end
