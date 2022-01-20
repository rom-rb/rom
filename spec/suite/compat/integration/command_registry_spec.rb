# frozen_string_literal: true

RSpec.describe "ROM::CommandRegistry" do
  include_context "container"

  let(:users) { container.commands[:users] }

  before do
    configuration.relation(:users)

    configuration.register_command(Class.new(ROM::Commands::Create[:memory]) do
      register_as :create
      relation :users
    end)
  end

  describe "#[]" do
    it "fetches a command from the registry" do
      expect(users[:create]).to be_a(ROM::Commands::Create[:memory])
    end

    it "throws an error when the command is not found" do
      expect { users[:not_found] }.to raise_error(ROM::CommandNotFoundError, /not_found/)
    end
  end
end
