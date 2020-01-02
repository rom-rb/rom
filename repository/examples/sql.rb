# frozen_string_literal: true

require 'rom-repository'

conf = ROM::Configuration.new(:sql, 'sqlite::memory')

migration = conf.gateways[:default].migration do
  change do
    create_table(:users) do
      primary_key :id
      column :name, String, null: false
      column :email, String, null: false
    end
  end
end

migration.apply(conf.gateways[:default].connection, :up)

class Users < ROM::Relation[:sql]
  schema(infer: true)

  def by_id(id)
    where(id: id)
  end
end

conf.register_relation(Users)
rom = ROM.container(conf)

class UserRepo < ROM::Repository[:users]
  commands :create, update: :by_id, delete: :by_id

  def [](id)
    users.by_id(id).one!
  end

  def all
    users.to_a
  end
end

user_repo = UserRepo.new(rom)

user = user_repo.create(name: 'Jane', email: 'jane@doe.org')

puts user.inspect

user_repo.update(user.id, name: 'Jane Doe')

puts user_repo[user.id].inspect

user_repo.delete(user.id)

puts user_repo.all.inspect
