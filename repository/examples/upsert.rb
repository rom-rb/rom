# frozen_string_literal: true

require 'rom'
require 'rom/repository'
require 'rom/changeset'

conf = ROM::Configuration.new(:sql, 'postgres://localhost/rom_example')

migration = conf.gateways[:default].migration do
  change do
    create_table?(:books) do
      primary_key :id
      column :title, String, null: false
    end

    create_table?(:tags) do
      primary_key :id
      column :name, String, null: false, unique: true
    end

    create_table?(:taggings) do
      foreign_key :tag_id, :tags, null: false
      foreign_key :book_id, :books, null: false
      primary_key [:tag_id, :book_id]
    end
  end
end

conn = conf.gateways[:default].connection

migration.apply(conn, :up)

class CreateTags < ROM::SQL::Commands::Postgres::Upsert
  relation :tags
  register_as :fetch_or_create
  result :many
  constraint 'tags_name_key'

  def execute(tuples, *)
    result = super

    if result.empty?
      relation.where(name: Array(tuples).map { |t| t[:name] }).to_a
    else
      result
    end
  end
end

class Books < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      has_many :taggings
      has_many :tags, through: :taggings
    end
  end
end

class Taggings < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      belongs_to :tag
      belongs_to :book
    end
  end
end

class Tags < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      has_many :taggings
      has_many :books, through: :taggings
    end
  end
end

conf.register_relation(Tags, Taggings, Books)
conf.register_command(CreateTags)

rom = ROM.container(conf)

books = rom.relations[:books]
tags = rom.relations[:tags]

book = rom.relations[:books].changeset(:create, title: 'Hello World')

tags = rom.relations[:tags]
  .changeset(:create, [{ name: 'red' }, { name: 'green' }])
  .with(command_type: :fetch_or_create)

# return tags associated with the book
books.transaction do
  puts book.associate(tags, :books).commit.inspect
end

# return book associated with the tags
books.transaction do
  puts tags.associate(book, :tags).commit.inspect
end

# commit separately and return what you need
books.transaction do
  new_tags = tags.commit
  new_book = book.associate(new_tags, :tags).commit

  puts new_book.inspect
end
