require 'spec_helper'

describe ROM::Commands::Lazy do
  let(:rom) { setup.finalize }
  let(:setup) { ROM.setup(:memory) }

  let(:create_user) { rom.command(:users).create }
  let(:update_user) { rom.command(:users).update }
  let(:create_task) { rom.command(:tasks).create }

  let(:user) { { user: { name: 'Jane' } } }
  let(:evaluator) { -> input { input[:user] } }

  before do
    setup.relation(:tasks) do
      def by_title(title)
        restrict(title: title)
      end
    end

    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end

    setup.commands(:users) do
      define(:create) do
        result :one
      end

      define(:update)
    end

    setup.commands(:tasks) do
      define(:create)
    end
  end

  describe '#call' do
    context 'with a create command' do
      subject(:command) { ROM::Commands::Lazy.new(create_user, evaluator) }

      it 'evaluates the input and calls command' do
        command.call(user)

        expect(rom.relation(:users)).to match_array([
          { name: 'Jane' }
        ])
      end
    end
  end

  describe '#>>' do
    subject(:command) { ROM::Commands::Lazy.new(create_user, evaluator) }

    it 'composes with another command' do
      expect(command >> create_task).to be_instance_of(ROM::Commands::Composite)
    end
  end

  describe '#combine' do
    subject(:command) { ROM::Commands::Lazy.new(create_user, evaluator) }

    it 'combines with another command' do
      expect(command.combine(create_task)).to be_instance_of(ROM::Commands::Graph)
    end
  end

  describe '#method_missing' do
    subject(:command) { ROM::Commands::Lazy.new(update_user, evaluator) }

    it 'forwards to command' do
      rom.relations[:users] << { name: 'Jane' } << { name: 'Joe' }

      new_command = command.by_name('Jane')
      new_command.call(user: { name: 'Jane Doe' })

      expect(rom.relation(:users)).to match_array([
        { name: 'Jane Doe' },
        { name: 'Joe' }
      ])
    end

    it 'returns original response if it was not a command' do
      response = command.result
      expect(response).to be(:many)
    end

    it 'raises error when message is unknown' do
      expect { command.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
