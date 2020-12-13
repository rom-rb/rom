# frozen_string_literal: true

require "rom/command"
require "rom/memory"

RSpec.describe ROM::Commands::Create[:memory], "before/after hooks" do
  let(:dataset) do
    spy(:dataset)
  end

  describe "#before" do
    subject(:command) do
      Class.new(ROM::Commands::Create[:memory]) do
        before :init
        before :normalize

        def init(*); end

        def normalize(*); end

        def prepare(*); end
      end.build(dataset)
    end

    it "returns a new command with configured before hooks" do
      expect(command.before(:prepare).before_hooks).to eql(%i[init normalize prepare])
    end
  end

  describe "#after" do
    subject(:command) do
      Class.new(ROM::Commands::Create[:memory]) do
        after :finalize
        after :filter

        def finalize(*); end

        def filter(*); end

        def prepare(*); end
      end.build(dataset)
    end

    it "returns a new command with configured after hooks" do
      expect(command.after(:prepare).after_hooks).to eql(%i[finalize filter prepare])
    end

    it "worker with before" do
      with_before_and_after = command.before(:filter).after(:finalize)

      expect(with_before_and_after.before_hooks).to eql(%i[filter])
      expect(with_before_and_after.after_hooks).to eql(%i[finalize filter finalize])
    end
  end

  context "without curried args" do
    subject(:command) do
      Class.new(ROM::Commands::Create[:memory]) do
        result :many
        before :prepare
        after :finalize

        def execute(tuples)
          input = tuples.map.with_index { |tuple, idx| tuple.merge(id: idx + 1) }
          dataset.insert(input)
          input
        end

        def prepare(tuples)
          tuples.map { |tuple| tuple.merge(prepared: true) }
        end

        def finalize(tuples)
          tuples.map { |tuple| tuple.merge(finalized: true) }
        end
      end.build(dataset)
    end

    let(:tuples) do
      [{name: "Jane"}, {name: "Joe"}]
    end

    it "applies before/after hooks" do
      insert_tuples = [
        {id: 1, name: "Jane", prepared: true},
        {id: 2, name: "Joe", prepared: true}
      ]

      result = [
        {id: 1, name: "Jane", prepared: true, finalized: true},
        {id: 2, name: "Joe", prepared: true, finalized: true}
      ]

      expect(command.call(tuples)).to eql(result)

      expect(dataset).to have_received(:insert).with(insert_tuples)
    end
  end

  context "with one curried arg" do
    subject(:command) do
      Class.new(ROM::Commands::Create[:memory]) do
        result :many
        before :prepare
        after :finalize

        def execute(tuples)
          input = tuples.map.with_index { |tuple, idx| tuple.merge(id: idx + 1) }
          dataset.insert(input)
          input
        end

        def prepare(tuples, name)
          tuples.map.with_index { |tuple, idx| tuple.merge(name: "#{name} #{idx + 1}") }
        end

        def finalize(tuples, *)
          tuples.map { |tuple| tuple.merge(finalized: true) }
        end
      end.build(dataset)
    end

    let(:tuples) do
      [{email: "user-1@test.com"}, {email: "user-2@test.com"}]
    end

    let(:dataset) do
      spy(:dataset)
    end

    it "applies before/after hooks" do
      insert_tuples = [
        {id: 1, email: "user-1@test.com", name: "User 1"},
        {id: 2, email: "user-2@test.com", name: "User 2"}
      ]

      result = [
        {id: 1, email: "user-1@test.com", name: "User 1", finalized: true},
        {id: 2, email: "user-2@test.com", name: "User 2", finalized: true}
      ]

      expect(command.curry(tuples).call("User")).to eql(result)

      expect(dataset).to have_received(:insert).with(insert_tuples)
    end
  end

  context "with 2 curried args" do
    subject(:command) do
      Class.new(ROM::Commands::Create[:memory]) do
        result :many
        before :prepare
        after :finalize

        def execute(tuples)
          input = tuples.map.with_index { |tuple, idx| tuple.merge(id: idx + 1) }
          dataset.insert(input)
          input
        end

        def prepare(tuples, name)
          tuples.map.with_index { |tuple, idx| tuple.merge(name: "#{name} #{idx + 1}") }
        end

        def finalize(tuples, *)
          tuples.map { |tuple| tuple.merge(finalized: true) }
        end
      end.build(dataset)
    end

    let(:tuples) do
      [{email: "user-1@test.com"}, {email: "user-2@test.com"}]
    end

    let(:dataset) do
      spy(:dataset)
    end

    it "applies before/after hooks" do
      insert_tuples = [
        {id: 1, email: "user-1@test.com", name: "User 1"},
        {id: 2, email: "user-2@test.com", name: "User 2"}
      ]

      result = [
        {id: 1, email: "user-1@test.com", name: "User 1", finalized: true},
        {id: 2, email: "user-2@test.com", name: "User 2", finalized: true}
      ]

      expect(command.curry(tuples, "User").call).to eql(result)

      expect(dataset).to have_received(:insert).with(insert_tuples)
    end
  end

  context "with pre-set opts" do
    subject(:command) do
      Class.new(ROM::Commands::Create[:memory]) do
        result :many
        before prepare: {prepared: true}
        after finalize: {finalized: true}

        def execute(tuples)
          input = tuples.map.with_index { |tuple, idx| tuple.merge(id: idx + 1) }
          dataset.insert(input)
          input
        end

        def prepare(tuples, opts)
          tuples.map { |tuple| tuple.merge(opts) }
        end

        def finalize(tuples, opts)
          tuples.map { |tuple| tuple.merge(opts) }
        end
      end.build(dataset)
    end

    let(:tuples) do
      [{name: "Jane"}, {name: "Joe"}]
    end

    let(:dataset) do
      spy(:dataset)
    end

    it "applies before/after hooks" do
      insert_tuples = [
        {id: 1, name: "Jane", prepared: true},
        {id: 2, name: "Joe", prepared: true}
      ]

      result = [
        {id: 1, name: "Jane", prepared: true, finalized: true},
        {id: 2, name: "Joe", prepared: true, finalized: true}
      ]

      expect(command.call(tuples)).to eql(result)

      expect(dataset).to have_received(:insert).with(insert_tuples)
    end
  end

  context "with pre-set opts for a curried command" do
    subject(:command) do
      Class.new(ROM::Commands::Create[:memory]) do
        result :many
        before prepare: {prepared: true}
        after finalize: {finalized: true}

        def execute(tuples)
          input = tuples.map.with_index { |tuple, idx| tuple.merge(id: idx + 1) }
          dataset.insert(input)
          input
        end

        def prepare(tuples, parent, opts)
          tuples.map { |tuple| tuple.merge(opts).merge(parent_size: parent.size) }
        end

        def finalize(tuples, parent, opts)
          tuples.map { |tuple| tuple.merge(opts).merge(user_id: parent[:id]) }
        end
      end.build(dataset)
    end

    let(:tuples) do
      [{name: "Jane"}, {name: "Joe"}]
    end

    let(:dataset) do
      spy(:dataset)
    end

    it "applies before/after hooks" do
      insert_tuples = [
        {id: 1, name: "Jane", parent_size: 1, prepared: true},
        {id: 2, name: "Joe", parent_size: 1, prepared: true}
      ]

      result = [
        {id: 1, name: "Jane", parent_size: 1, user_id: 1, prepared: true, finalized: true},
        {id: 2, name: "Joe", parent_size: 1, user_id: 1, prepared: true, finalized: true}
      ]

      expect(command.curry(tuples).call(id: 1)).to eql(result)

      expect(dataset).to have_received(:insert).with(insert_tuples)
    end
  end

  context "calling with multiple args" do
    subject(:command) do
      Class.new(ROM::Commands::Create[:memory]) do
        result :many
        before prepare: {prepared: true}
        after finalize: {finalized: true}

        def execute(tuples)
          input = tuples.map.with_index { |tuple, idx| tuple.merge(id: idx + 1) }
          dataset.insert(input)
          input
        end

        def prepare(tuples, parent, opts)
          tuples.map { |tuple| tuple.merge(opts).merge(parent_size: parent.size) }
        end

        def finalize(tuples, parent, opts)
          tuples.map { |tuple| tuple.merge(opts).merge(user_id: parent[:id]) }
        end
      end.build(dataset)
    end

    let(:tuples) do
      [{name: "Jane"}, {name: "Joe"}]
    end

    let(:dataset) do
      spy(:dataset)
    end

    it "applies before/after hooks" do
      insert_tuples = [
        {id: 1, name: "Jane", parent_size: 1, prepared: true},
        {id: 2, name: "Joe", parent_size: 1, prepared: true}
      ]

      result = [
        {id: 1, name: "Jane", parent_size: 1, user_id: 1, prepared: true, finalized: true},
        {id: 2, name: "Joe", parent_size: 1, user_id: 1, prepared: true, finalized: true}
      ]

      expect(command.call(tuples, id: 1)).to eql(result)

      expect(dataset).to have_received(:insert).with(insert_tuples)
    end
  end
end
