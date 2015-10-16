require 'spec_helper'

RSpec.describe 'Command graph DSL' do
  include_context 'command graph'

  it 'allows defining a create command graph' do
    setup.commands(:tasks) do
      define(:create) { result :one }
    end

    command = rom.command do
      create(:users, from: :user) >> (create(:tasks, from: :task) >> create(:tags))
    end

    other = rom.command([
      { user: :users }, [
        :create, [
          { task: :tasks }, [:create, [:tags, [:create]]]
        ]
      ]
    ])

    expect(command).to eql(other)
  end

  it 'allows defining a create command graph with command procs' do
    setup.commands(:users) do
      define(:update) { result :one }
    end

    setup.commands(:tasks) do
      define(:update) { result :many }
    end

    user_cmd_proc = -> cmd, user do
      cmd.by_name(user[:name])
    end

    task_cmd_proc = -> cmd, user, task do
      cmd.by_user_and_title(user[:name], task[:title])
    end

    command = rom.command do
      update(:users, from: :user, &user_cmd_proc)
        .>> update(:tasks, &task_cmd_proc)
    end

    other = rom.command([
      { user: :users },
      [
        { update: user_cmd_proc },
        [
          [
            :tasks,
            [{ update: task_cmd_proc }]
          ]
        ]
      ]
    ])

    expect(command).to eql(other)
  end

  it 'raises when unknown command is accessed' do
    expect {
      rom.command { not_here(:users) }
    }.to raise_error(ROM::Registry::ElementNotFoundError, /not_here/)
  end
end
