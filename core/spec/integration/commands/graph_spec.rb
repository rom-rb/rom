require 'spec_helper'

RSpec.describe 'Building up a command graph for nested input' do
  include_context 'command graph'

  it 'creates a command graph for nested input :one result as root' do
    configuration.commands(:tasks) do
      define(:create) do
        result :one
        before :associate

        def associate(tuple, user)
          tuple.merge(user: user.fetch(:name))
        end
      end
    end

    input = {
      user: {
        name: 'Jane',
        task: {
          title: 'Task One',
          tags: [
            { name: 'red' }, { name: 'green' }, { name: 'blue' }
          ]
        },
        books: [
          { title: 'Book One' },
          { title: 'Book Two' }
        ]
      }
    }

    options = [
      { user: :users }, [
        :create, [
          [{ task: :tasks }, [:create, [:tags, [:create]]]],
          [:books, [:create]]
        ]
      ]
    ]

    command = container.command(options)

    command.call(input)

    expect(container.relation(:users)).to match_array([
      { name: 'Jane' }
    ])

    expect(container.relation(:tasks)).to match_array([
      { title: 'Task One', user: 'Jane' }
    ])

    expect(container.relation(:books)).to match_array([
      { title: 'Book One', user: 'Jane' },
      { title: 'Book Two', user: 'Jane' }
    ])

    expect(container.relation(:tags)).to match_array([
      { name: 'red', task: 'Task One' },
      { name: 'green', task: 'Task One' },
      { name: 'blue', task: 'Task One' }
    ])
  end

  it 'creates a command graph for nested input with :many results as root' do
    configuration.commands(:tasks) do
      define(:create) do
        before :associate

        def associate(tuples, user)
          tuples.map { |t| t.merge(user: user.fetch(:name)) }
        end
      end
    end

    input = {
      user: {
        name: 'Jane',
        tasks: [
          {
            title: 'Task One',
            tags: [{ name: 'red' }, { name: 'green' }]
          },
          {
            title: 'Task Two',
            tags: [{ name: 'blue' }]
          }
        ]
      }
    }

    options = [
      { user: :users }, [
        :create, [
          [:tasks, [:create, [:tags, [:create]]]]
        ]
      ]
    ]

    command = container.command(options)

    command.call(input)

    expect(container.relation(:users)).to match_array([
      { name: 'Jane' }
    ])

    expect(container.relation(:tasks)).to match_array([
      { title: 'Task One', user: 'Jane' },
      { title: 'Task Two', user: 'Jane' }
    ])

    expect(container.relation(:tags)).to match_array([
      { name: 'red', task: 'Task One' },
      { name: 'green', task: 'Task One' },
      { name: 'blue', task: 'Task Two' }
    ])
  end


  it 'updates graph elements cleanly' do
    configuration.commands(:tasks) do
      define(:create) do
        before :associate

        def associate(tuples, user)
          tuples.map { |t| t.merge(user: user.fetch(:name)) }
        end
      end

      define(:update) do
        result :one
        before :associate

        def associate(tuple, user)
          tuple.merge(user: user.fetch(:name))
        end
      end

      define(:delete) do
        register_as :complete
        result :one
      end
    end

    configuration.commands(:users) do
      define(:update) do
        result :one
      end
    end

    initial = {
      user: {
        name: 'Johnny',
        email: 'johnny@doe.org',
        tasks: [
          { title: 'Change Name' },
          { title: 'Finish that novel' }
        ]
      }
    }

    updated = {
      user: {
        name: 'Johnny',
        email: 'johnathan@doe.org',
        completed: [{ title: 'Change Name' }],
        tasks: [{ title: 'Finish that novel', priority: 1 }]
      }
    }

    create = container.command([{ user: :users }, [:create, [:tasks, [:create]]]])

    update = container.command([
      { user: :users },
      [
        { update: -> cmd, user { cmd.by_name(user[:name]) } },
        [
          [
            { completed: :tasks },
            [{ complete: -> cmd, user, task { cmd.by_user_and_title(user[:name], task[:title]) } }]
          ],
          [
            :tasks,
            [{ update: -> cmd, user, task { cmd.by_user_and_title(user[:name], task[:title]) } }]
          ]
        ]
      ]
    ])

    create.call(initial)

    container.command(:tasks).create.with([{ title: 'Task One'}]).(name: 'Jane')

    expect(container.relation(:tasks)).to match_array([
      { title: 'Change Name', user: 'Johnny' },
      { title: 'Finish that novel', user: 'Johnny' },
      { title: 'Task One', user: 'Jane' }
    ])

    update.call(updated)

    expect(container.relation(:users)).to match_array([
      { name: 'Johnny', email: 'johnathan@doe.org' }
    ])

    expect(container.relation(:tasks)).to match_array([
      { title: 'Task One', user: 'Jane' },
      { title: 'Finish that novel', priority: 1, user: 'Johnny' }
    ])
  end


  it 'works with auto-mapping' do
    configuration.mappers do
      define(:users) do
        register_as :entity
        reject_keys true

        model name: 'Test::User'

        attribute :name

        combine :tasks, on: { name: :user } do
          model name: 'Test::Task'
          attribute :title

          combine :tags, on: { title: :task } do
            model name: 'Test::Tag'
            attribute :name
          end
        end
      end
    end

    configuration.commands(:tasks) do
      define(:create) do
        before :associate

        def associate(tuples, user)
          tuples.map { |t| t.merge(user: user.fetch(:name)) }
        end
      end
    end

    input = {
      user: {
        name: 'Jane',
        tasks: [
          {
            title: 'Task One',
            tags: [{ name: 'red' }, { name: 'green' }]
          },
          {
            title: 'Task Two',
            tags: [{ name: 'blue' }]
          }
        ]
      }
    }

    options = [
      { user: :users }, [
        :create, [
          [:tasks, [:create, [:tags, [:create]]]]
        ]
      ]
    ]

    command = container.command(options).as(:entity)

    result = command.call(input)

    expect(result).to be_instance_of(Test::User)
    expect(result.tasks.first).to be_instance_of(Test::Task)
    expect(result.tasks.first.tags.first).to be_instance_of(Test::Tag)
  end

  it 'raises a proper error when the input has invalid structure' do
    input = { user: { name: 'Jane' } }

    options = [
      { user: :users }, [:create, [{ book: :books }, [:create]]]
    ]

    command = container.command(options)

    expect {
      command.call(input)
    }.to raise_error(ROM::KeyMissing, /book/)
  end
end
