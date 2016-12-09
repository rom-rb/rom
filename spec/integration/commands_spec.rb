require 'spec_helper'

RSpec.describe 'Commands' do
  include_context 'container'
  include_context 'users and tasks'

  before do
    configuration.relation(:users) do
      def by_id(id)
        restrict(id: id)
      end
    end

    configuration.commands(:users) do
      define(:update)
      define(:create)
    end
  end

  let(:create) { container.command(:users)[:create] }
  let(:update) { container.command(:users)[:update] }

  describe '#method_missing' do
    it 'forwards known relation view methods' do
      expect(update.by_id(1).relation).to eql(users_relation.by_id(1))
    end

    it 'raises no-method error when a non-view relation method was sent' do
      expect { update.as(:foo) }.to raise_error(NoMethodError, /as/)
    end

    it 'does not forward relation view methods to non-restrictable commands' do
      expect { create.by_id(1) }.to raise_error(NoMethodError, /by_id/)
    end
  end

  describe 'extending command with a db-specific behavior' do
    before do
      gateway.instance_exec do
        def extend_command_class(klass, _)
          klass.class_eval do
            def super_command?
              true
            end
          end
          klass
        end
      end
    end

    it 'applies to defined classes' do
      klass = Class.new(ROM::Commands::Create[:memory]) { relation :users }
      configuration.register_command(klass)
      container
      command = klass.build(users_relation)
      expect(command).to be_super_command
    end

    it 'applies to generated classes' do
      klass = ROM::ConfigurationDSL::Command.build_class(:create, :users, adapter: :memory)
      configuration.register_command(klass)
      container
      command = klass.build(users_relation)
      expect(command).to be_super_command
    end
  end
end
