[gem]: https://rubygems.org/gems/rom-repository
[travis]: https://travis-ci.org/rom-rb/rom-repository
[gemnasium]: https://gemnasium.com/rom-rb/rom-repository
[codeclimate]: https://codeclimate.com/github/rom-rb/rom-repository
[inchpages]: http://inch-ci.org/github/rom-rb/rom-repository

# ROM::Repository

[![Gem Version](https://badge.fury.io/rb/rom-repository.svg)][gem]
[![Build Status](https://travis-ci.org/rom-rb/rom-repository.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/rom-rb/rom-repository.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/rom-rb/rom-repository/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/rom-rb/rom-repository/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/rom-rb/rom-repository.svg?branch=master)][inchpages]

Repository for [ROM](https://github.com/rom-rb/rom) with auto-mapping and relation
extensions.

## Synopsis

``` ruby
require 'rom-repository'

ROM.setup(:sql, 'postgres://localhost/rom')

class UserRepository < ROM::Repository::Base
  relations :users, :tasks

  def by_id(id)
    users.find(id: id)
  end

  def with_tasks
    users.combine_children(many: tasks)
  end
end

rom = ROM.finalize.env

user_repo = UserRepository.new(rom)

puts user_repo.by_id(1).to_a.inspect
# [#<ROM::Struct[User] id=1 name="Jane">]

puts user_repo.with_tasks.to_a.inspect
# [#<ROM::Struct[User] id=1 name="Jane" tasks=[#<ROM::Struct[Task] id=2 user_id=1 title="Jane Task">]>, #<ROM::Struct[User] id=2 name="Joe" tasks=[#<ROM::Struct[Task] id=1 user_id=2 title="Joe Task">]>]
```
