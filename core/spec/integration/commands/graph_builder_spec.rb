require 'spec_helper'

RSpec.describe 'Command graph builder' do
  include_context 'command graph'

  it 'allows defining a simple create command graph' do
    command = container.command.create(user: :users)

    other = container.command([{ user: :users }, [:create]])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph with simple nesting' do
    configuration.commands(:books) do
      define(:create) { result :many }
    end

    command = container.command.create(user: :users) do |user|
      user.create(:books)
    end

    other = container.command([{ user: :users }, [:create, [
      [{ books: :books }, [:create]]
    ]]])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph with multiple levels of nesting' do
    configuration.commands(:books) do
      define(:create) { result :many }
    end

    configuration.commands(:tags) do
      define(:create) { result :many }
    end

    command = container.command.create(user: :users) do |user|
      user.create(novels: :books) do |novels|
        novels.create(:tags)
      end
    end

    other = container.command([{ user: :users }, [:create, [
      [{ novels: :books }, [:create, [
        [{ tags: :tags }, [:create]]
      ]]]
    ]]])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph with multiple nested commands' do
    configuration.commands(:books) do
      define(:create) { result :many }
    end

    configuration.commands(:tags) do
      define(:create) { result :many }
    end

    command = container.command.create(user: :users) do |user|
      user.create(:books)
      user.create(tag: :tags)
    end

    other = container.command([{ user: :users }, [:create, [
      [{ books: :books }, [:create]],
      [{ tag: :tags }, [:create]]
    ]]])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph with multiple nested commands in multiple levels' do
    configuration.commands(:tasks) do
      define(:create) { result :many }
    end

    configuration.commands(:books) do
      define(:create) { result :many }
    end

    configuration.commands(:tags) do
      define(:create) { result :many }
    end

    command = container.command.create(user: :users) do |user|
      user.create(:tasks).each do |task|
        task.create(:tags)
      end
      user.create(:books).each do |book|
        book.create(:tags)
        book.create(:tasks)
      end
    end

    other = container.command([{ user: :users }, [:create, [
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
    configuration.commands(:books) do
      define(:create) { result :many }
    end

    command = container.command.create(user: :users) do |user|
      user.create(novels: :books).each do |novel|
        novel.create(:tags)
      end
    end

    other = container.command([{ user: :users }, [:create, [
      [{ novels: :books }, [:create, [
        [{ tags: :tags }, [:create]]
      ]]]
    ]]])

    expect(command).to eql(other)
  end

  it 'allows restricting a relation with a proc' do
    configuration.commands(:users) do
      define(:update) { result :one }
    end

    configuration.commands(:tasks) do
      define(:update) { result :many }
    end

    users_proc = -> users, user do
      users.by_name(user[:name])
    end

    tasks_proc = -> tasks, user, task do
      tasks.by_user_and_title(user[:name], task[:title])
    end

    users = container.command.restrict(:users, &users_proc)
    command = container.command.update(user: users) do |user|
      tasks = user.restrict(:tasks, &tasks_proc)
      user.update(tasks)
    end

    other = container.command([
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
    configuration.commands(:users) do
      define(:update) { result :one }
    end

    configuration.commands(:tasks) do
      define(:update) { result :many }
    end

    users_proc = -> users, user do
      users.by_name(user[:name])
    end

    tasks_proc = -> tasks, user, task do
      tasks.by_user_and_title(user[:name], task[:title])
    end

    command = container.command.restrict(:users, &users_proc).update(from: :user) do |user|
      user.restrict(:tasks, &tasks_proc).update
    end

    other = container.command([
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
      container.command.not_here(:users)
    }.to raise_error(ROM::CommandRegistry::CommandNotFoundError, /not_here/)
  end
end
