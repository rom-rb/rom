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
end
