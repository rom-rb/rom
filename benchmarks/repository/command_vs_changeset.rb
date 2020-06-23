# frozen_string_literal: true

require_relative "setup"

benchmark("create command vs changeset") do |x|
  x.report("command") do
    users.command(:create).call(name: "Jane", email: "jane@doe.org", age: 21)
  end

  x.report("changeset") do
    users.changeset(:create, name: "Jane", email: "jane@doe.org", age: 21).commit
  end

  x.compare!
end

benchmark("update command vs changeset") do |x|
  x.prepare do
    users.command(:create).call(name: "Jane", email: "jane@doe.org", age: 21)
    users.command(:create).call(name: "John", email: "john@doe.org", age: 21)
  end

  x.report("command") do
    users.where(name: "Jane").command(:update).call(name: "Jane Doe")
  end

  x.report("changeset") do
    users.where(name: "Jane").changeset(:update, name: "Jane Doe").commit
  end

  x.compare!
end

benchmark("delete command vs changeset") do |x|
  x.report("command") do
    users.command(:create).call(name: "Jane", email: "jane@doe.org", age: 21)
  end

  x.report("changeset") do
    users.changeset(:create, name: "Jane", email: "jane@doe.org", age: 21).commit
  end

  x.compare!
end
