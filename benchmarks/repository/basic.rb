# frozen_string_literal: true

require_relative "setup"

benchmark("creating a user") do |x|
  x.report("rom-repository") do
    user_repo.create(name: "Jane", email: "jane@doe.org", age: 21)
  end

  x.report("rom-repository with a changeset") do
    changeset = user_repo.users.changeset(:create, name: "Jane", email: "jane@doe.org", age: 21)
    user_repo.create(changeset)
  end

  x.report("sequel") do
    Sequel::User.create(name: "Jane", email: "jane@doe.org", age: 21)
  end

  x.report("activerecord") do
    AR::User.create(name: "Jane", email: "jane@doe.org", age: 21)
  end

  x.compare!
end

benchmark("creating and updating a user") do |x|
  x.report("rom-repository") do
    user = user_repo.create(name: "Jane", email: "jane@doe.org", age: 21)

    user_repo.update(user.id, name: "Jane Doe")
  end

  x.report("rom-repository with a changeset") do
    user = user_repo.create(name: "Jane", email: "jane@doe.org", age: 21)
    changeset = user_repo.users.by_pk(user.id).changeset(:update, name: "Jane Doe")

    user_repo.update(user.id, changeset)
  end

  x.report("sequel") do
    user = Sequel::User.create(name: "Jane", email: "jane@doe.org", age: 21)

    updated_user = Sequel::User[user.id]
    updated_user.name = "Jane Doe"
    updated_user.save
  end

  x.report("activerecord") do
    user = AR::User.create(name: "Jane", email: "jane@doe.org", age: 21)

    updated_user = AR::User.find(user.id)
    updated_user.name = "Jane Doe"
    updated_user.save
  end

  x.compare!
end
