# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Commands" do
  include_context "container"
  include_context "users and tasks"

  before do
    configuration.relation(:users)

    configuration.commands(:users) do
      define(:update)
      define(:create)
    end
  end

  let(:create) { container.commands[:users][:create] }
  let(:update) { container.commands[:users][:update] }

  describe "extending command with a db-specific behavior" do
    before do
      configuration.notifications.subscribe("configuration.commands.class.before_build") do |event|
        payload = event.to_h
        command = payload.fetch(:command)
        %i[adapter gateway dataset].each { |expected_key| payload.fetch(expected_key) }

        unless command.instance_methods.include?(:super_command?)
          command.class_eval do
            def super_command?
              true
            end
          end
        end
      end
    end

    it "applies to defined classes" do
      klass = Class.new(ROM::Commands::Create[:memory]) do
        relation :users
        register_as :create_super
      end

      configuration.register_command(klass)
      command = container.commands[:users][:create_super]
      expect(command).to be_super_command
    end

    it "applies to generated classes" do
      klass = ROM::ConfigurationDSL::Command.build_class(
        :create_super, :users, type: :create, adapter: :memory
      )
      configuration.register_command(klass)
      command = container.commands[:users][:create_super]
      expect(command).to be_super_command
    end
  end
end
