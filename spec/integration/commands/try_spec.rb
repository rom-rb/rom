require 'spec_helper'

describe 'Commands / Control Flow' do
  include_context 'users and tasks'

  before do
    setup.relation(:users)
    setup.commands(:users) { define(:create) }
  end

  subject(:users) { rom.commands.users }

  let(:on_success) { RecordCalls.new { |value, result| result.success(value) } }
  let(:on_failure) { RecordCalls.new { |error, result| result.failure(error) } }

  describe "a successful command" do
    let(:run_command) do
      users.try {
        users.create.call(name: "Bob")
      }.and_then(&on_success).or_else(&on_failure)
    end

    before do
      run_command
    end

    it "calls the block registered via #and_then" do
      expect(on_success.call_count).to eq(1)
      expect(on_success.calls.first).to eq [[{ name: "Bob" }], ROM::Commands::Result]
    end

    it "ignores the block registered via #or_else" do
      expect(on_failure.call_count).to eq(0)
    end
  end

  describe "an unsuccessful command" do
    let(:run_command) do
      users.try {
        raise error
      }.and_then(&on_success).or_else(&on_failure)
    end

    let(:error) { ROM::CommandError.new }

    before do
      run_command
    end

    it "ignores the block registered via #and_then" do
      expect(on_success.call_count).to eq(0)
    end

    it "calls the block registered via #or_else" do
      expect(on_failure.call_count).to eq(1)
      expect(on_failure.calls.first).to eq [error, ROM::Commands::Result]
    end
  end

  describe "chaining" do
    let(:run_command) do
      users.try {
        users.create.call(name: "Bob")
      }.and_then(&upcase_names).and_then(&on_success)
    end

    let(:upcase_names) do
      proc { |users, result|
        result.success(
          users.map { |user|
            user.tap do |user|
              user[:name] = user[:name].upcase
            end
          }
        )
      }
    end

    before do
      run_command
    end

    it "calls each block with the result of the previous" do
      expect(on_success.call_count).to eq(1)
      expect(on_success.calls.first).to eq [[{ name: "BOB" }], ROM::Commands::Result]
    end
  end
end
