require 'spec_helper'

RSpec.describe 'Command graph builder' do
  include_context 'command graph'

  it 'allows defining a simple create command graph' do
    command = rom.command.create(user: :users)

    other = rom.command([{ user: :users }, [:create]])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph with simple nesting' do
    setup.commands(:books) do
      define(:create) { result :many }
    end

    command = rom.command.create(user: :users) do |user|
      user.create(:books)
    end

    other = rom.command([{ user: :users }, [:create, [
      [{ books: :books }, [:create]]
    ]]])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph with multiple levels of nesting' do
    setup.commands(:books) do
      define(:create) { result :many }
    end

    setup.commands(:tags) do
      define(:create) { result :many }
    end

    command = rom.command.create(user: :users) do |user|
      user.create(novels: :books) do |novels|
        novels.create(:tags)
      end
    end

    other = rom.command([{ user: :users }, [:create, [
      [{ novels: :books }, [:create, [
        [{ tags: :tags }, [:create]]
      ]]]
    ]]])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph with multiple nested commands' do
    setup.commands(:books) do
      define(:create) { result :many }
    end

    setup.commands(:tags) do
      define(:create) { result :many }
    end

    command = rom.command.create(user: :users) do |user|
      user.create(:books)
      user.create(tag: :tags)
    end

    other = rom.command([{ user: :users }, [:create, [
      [{ books: :books }, [:create]],
      [{ tag: :tags }, [:create]]
    ]]])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph with multiple nested commands in multiple levels' do
    setup.commands(:tasks) do
      define(:create) { result :many }
    end

    setup.commands(:books) do
      define(:create) { result :many }
    end

    setup.commands(:tags) do
      define(:create) { result :many }
    end

    command = rom.command.create(user: :users) do |user|
      user.create(:tasks).each do |task|
        task.create(:tags)
      end
      user.create(:books).each do |book|
        book.create(:tags)
        book.create(:tasks)
      end
    end

    other = rom.command([{ user: :users }, [:create, [
      [{ tasks: :tasks }, [:create, [
        [{ tags: :tags }, [:create]]
      ]]],
      [{ books: :books }, [:create, [
        [{ tags: :tags }, [:create]],
        [{ tasks: :tasks }, [:create]]
      ]]]
    ]]])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph using the each sugar' do
    setup.commands(:books) do
      define(:create) { result :many }
    end

    command = rom.command.create(user: :users) do |user|
      user.create(novels: :books).each do |novel|
        novel.create(:tags)
      end
    end

    other = rom.command([{ user: :users }, [:create, [
      [{ novels: :books }, [:create, [
        [{ tags: :tags }, [:create]]
      ]]]
    ]]])

    expect(command).to eql(other)
  end

  it 'allows restricting a relation with a proc' do
    setup.commands(:users) do
      define(:update) { result :one }
    end

    setup.commands(:tasks) do
      define(:update) { result :many }
    end

    users_proc = -> users, user do
      users.by_name(user[:name])
    end

    tasks_proc = -> tasks, user, task do
      tasks.by_user_and_title(user[:name], task[:title])
    end

    users = rom.command.restrict(:users, &users_proc)
    command = rom.command.update(user: users) do |user|
      tasks = user.restrict(:tasks, &tasks_proc)
      user.update(tasks)
    end

    other = rom.command([
      { user: :users },
      [
        { update: users_proc },
        [
          [
            :tasks,
            [{ update: tasks_proc }]
          ]
        ]
      ]
    ])

    expect(command).to eql(other)
  end
  
  it 'allows chaining a command to a restriction' do
    setup.commands(:users) do
      define(:update) { result :one }
    end

    setup.commands(:tasks) do
      define(:update) { result :many }
    end

    users_proc = -> users, user do
      users.by_name(user[:name])
    end

    tasks_proc = -> tasks, user, task do
      tasks.by_user_and_title(user[:name], task[:title])
    end

    command = rom.command.restrict(:users, &users_proc).update(from: :user) do |user|
      user.restrict(:tasks, &tasks_proc).update
    end
    
    other = rom.command([
      { user: :users },
      [
        { update: users_proc },
        [
          [
            :tasks,
            [{ update: tasks_proc }]
          ]
        ]
      ]
    ])

    expect(command).to eql(other)
  end

  it 'raises when unknown command is accessed' do
    expect {
      rom.command.not_here(:users)
    }.to raise_error(ROM::Registry::ElementNotFoundError, /not_here/)
  end
end
