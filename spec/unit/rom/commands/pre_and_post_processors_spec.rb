require 'rom/command'

RSpec.describe ROM::Command, 'before/after hooks' do
  let(:relation) do
    spy(:relation)
  end

  describe '#before' do
    subject(:command) do
      Class.new(ROM::Command) do
        def prepare(*)
        end
      end.build(relation)
    end

    it 'returns a new command with configured before hooks' do
      expect(command.before(:prepare).before_hooks).to include(:prepare)
    end
  end

  describe '#after' do
    subject(:command) do
      Class.new(ROM::Command) do
        def prepare(*)
        end
      end.build(relation)
    end

    it 'returns a new command with configured after hooks' do
      expect(command.after(:prepare).after_hooks).to include(:prepare)
    end
  end

  context 'without curried args' do
    subject(:command) do
      Class.new(ROM::Command) do
        result :many
        before :prepare
        after :finalize

        def execute(tuples)
          input = tuples.map.with_index { |tuple, idx| tuple.merge(id: idx + 1) }
          relation.insert(input)
          input
        end

        def prepare(tuples)
          tuples.map { |tuple| tuple.merge(prepared: true) }
        end

        def finalize(tuples)
          tuples.map { |tuple| tuple.merge(finalized: true) }
        end
      end.build(relation)
    end

    let(:tuples) do
      [{ name: 'Jane' }, { name: 'Joe' }]
    end

    it 'applies before/after hooks' do
      insert_tuples = [
        { id: 1, name: 'Jane', prepared: true },
        { id: 2, name: 'Joe', prepared: true }
      ]

      result = [
        { id: 1, name: 'Jane', prepared: true, finalized: true },
        { id: 2, name: 'Joe', prepared: true, finalized: true }
      ]

      expect(command.call(tuples)).to eql(result)

      expect(relation).to have_received(:insert).with(insert_tuples)
    end
  end

  context 'with extra args' do
    subject(:command) do
      Class.new(ROM::Command) do
        result :many
        before :prepare
        after :finalize

        def execute(tuples)
          input = tuples.map.with_index { |tuple, idx| tuple.merge(id: idx + 1) }
          relation.insert(input)
          input
        end

        def prepare(tuples, name)
          tuples.map.with_index { |tuple, idx| tuple.merge(name: "#{name} #{idx + 1}") }
        end

        def finalize(tuples)
          tuples.map { |tuple| tuple.merge(finalized: true) }
        end
      end.build(relation)
    end

    let(:tuples) do
      [{ email: 'user-1@test.com' }, { email: 'user-2@test.com' }]
    end

    let(:relation) do
      spy(:relation)
    end

    it 'applies before/after hooks' do
      insert_tuples = [
        { id: 1, email: 'user-1@test.com', name: 'User 1' },
        { id: 2, email: 'user-2@test.com', name: 'User 2' }
      ]

      result = [
        { id: 1, email: 'user-1@test.com', name: 'User 1', finalized: true },
        { id: 2, email: 'user-2@test.com', name: 'User 2', finalized: true }
      ]

      expect(command.with(tuples).call('User')).to eql(result)

      expect(relation).to have_received(:insert).with(insert_tuples)
    end
  end
end
