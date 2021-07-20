# frozen_string_literal: true

require "rom/command"
require "rom/plugins/command/timestamps"

RSpec.describe ROM::Plugins::Command::Timestamps do
  include_context "container"

  let(:users) { container.commands.users }
  let(:tasks) { container.commands.tasks }
  let(:time) { DateTime.now }

  before do
    configuration.relation :users do
      def by_name(name)
        restrict(name: name)
      end
    end

    configuration.relation :tasks do
      def by_priority(priority)
        restrict(priority: priority)
      end
    end

    configuration.commands(:users) do
      define :create_with_timestamps_options, type: :create do
        result :one
        use :timestamps, timestamps: %i[created_at updated_at]
      end

      define :create_with_datestamps_options, type: :create do
        result :one
        use :timestamps, datestamps: :written
      end

      define :create_with_both_options, type: :create do
        result :one
        use :timestamps, timestamps: %i[created_at updated_at], datestamps: :written
      end

      define :create do
        result :one
        use :timestamps
        timestamp :updated_at, :created_at
        datestamp :written
      end

      define :create_many, type: :create do
        result :many
        use :timestamps
        timestamp :updated_at, :created_at
      end

      define :update do
        use :timestamps
        timestamp :updated_at
      end

      define :create_with_task, type: :create do
        result :one
        use :timestamps
        timestamp :updated_at, :created_at

        before :assign_task
        def assign_task(tuple, task)
          tuple.merge(task_id: task[:id])
        end
      end
    end

    configuration.commands(:tasks) do
      define :create do
        result :one
      end
    end
  end

  shared_examples_for "a command setting timestamps" do
    let(:user_command) { users.public_send(command) }
    let(:result) { user_command.call(name: "Piotr", email: "piotr@solnic.eu") }

    it "applies timestamps by default" do
      created = DateTime.parse(result[:created_at].to_s)
      updated = DateTime.parse(result[:updated_at].to_s)

      expect(created).to be_within(1).of(time)
      expect(updated).to eq created
    end
  end

  shared_examples_for "a command setting datestamp" do
    let(:user_command) { users.public_send(command) }
    let(:result) { user_command.call(name: "Piotr", email: "piotr@solnic.eu") }

    it "applies datestamps by default" do
      expect(Date.parse(result[:written].to_s)).to eq Date.today
    end
  end

  it_behaves_like "a command setting timestamps" do
    let(:command) { :create_with_timestamps_options }
  end

  it_behaves_like "a command setting datestamp" do
    let(:command) { :create_with_datestamps_options }
  end

  it_behaves_like "a command setting timestamps" do
    let(:command) { :create_with_both_options }
  end

  it_behaves_like "a command setting datestamp" do
    let(:command) { :create_with_both_options }
  end

  it_behaves_like "a command setting timestamps" do
    let(:command) { :create }
  end

  it_behaves_like "a command setting datestamp" do
    let(:command) { :create }
  end

  it "sets timestamps on multi-tuple inputs" do
    input = [{text: "note one"}, {text: "note two"}]

    results = users.create_many.call(input)

    results.each do |result|
      created = DateTime.parse(result[:created_at].to_s)

      expect(created).to be_within(1).of(time)
    end
  end

  it "only updates specified timestamps" do
    initial = users.create.call(name: "Piotr", email: "piotr@solnic.eu")
    initial_updated_at = initial[:updated_at]
    sleep 1 # Unfortunate, but unless I start injecting clocks into the
    # command, this is needed to make sure the time actually changes
    updated = users.update.call(name: "Piotr Updated").first
    expect(updated[:created_at]).to eq initial[:created_at]
    expect(updated[:updated_at]).not_to eq initial_updated_at
  end

  it "allows overriding timestamps" do
    tomorrow = (Time.now + (60 * 60 * 24))

    users.create.call(name: "Piotr", email: "piotr@solnic.eu")
    updated = users.update.call(name: "Piotr Updated", updated_at: tomorrow).first

    expect(updated[:updated_at].iso8601).to eql(tomorrow.iso8601)
  end

  it "works with chained commands" do
    create_user = tasks.create.curry(name: "ROM-RB", title: "Work on OSS", priority: 1)
    create_note = users.create_with_task.curry(name: "Piotr")

    command = create_user >> create_note

    result = command.call

    created = DateTime.parse(result[:created_at].to_s)
    updated = DateTime.parse(result[:updated_at].to_s)

    expect(created).to be_within(1).of(time)
    expect(updated).to eq created
  end
end
