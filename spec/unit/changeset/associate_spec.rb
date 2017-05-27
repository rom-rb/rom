require 'spec_helper'

RSpec.describe ROM::Changeset, '#associate' do
  include_context 'database setup'

  before do
    [:todos, :projects, :people].each { |table| conn.drop_table?(table) }

    conn.create_table :people do
      primary_key :id
      column :name, String
    end

    conn.create_table :projects do
      primary_key :id
      column :name, String
    end

    conn.create_table :todos do
      primary_key :id
      foreign_key :user_id, :people, null: false, on_delete: :cascade
      foreign_key :project_id, :projects, null: true, on_delete: :cascade
      column :title, String
    end

    configuration.relation(:people) do
      schema(infer: true) do
        associations do
          has_many :todos
        end
      end
    end

    configuration.relation(:projects) do
      schema(infer: true) do
        associations do
          has_many :todos
        end
      end
    end

    configuration.relation(:todos) do
      schema(infer: true) do
        associations do
          belongs_to :people, as: :user
          belongs_to :projects, as: :project
        end
      end
    end
  end

  let(:user_repo) do
    Class.new(ROM::Repository[:people]) { commands :create }.new(rom)
  end

  let(:project_repo) do
    Class.new(ROM::Repository[:projects]) { commands :create }.new(rom)
  end

  let(:task_repo) do
    Class.new(ROM::Repository[:todos]) { commands :create }.new(rom)
  end

  context 'with Create' do
    let(:jane) do
      user_repo.create(name: 'Jane')
    end

    let(:project) do
      project_repo.create(name: 'rom-rb')
    end

    it 'associates child with parent' do
      changeset = task_repo.changeset(title: 'Test 1').associate(jane, :user)

      expect(changeset.commit).to include(user_id: jane.id, title: 'Test 1')
    end

    it 'associates child with multiple parents' do
      changeset = task_repo.changeset(title: 'Test 1').
                    associate(jane, :user).
                    associate(project)

      expect(changeset.commit).
        to include(user_id: jane.id, project_id: project.id, title: 'Test 1')
    end

    it 'raises when assoc name cannot be inferred' do
      other = Class.new do
        def self.schema
          []
        end
      end.new

      expect { task_repo.changeset(title: 'Test 1').associate(other) }.
        to raise_error(ArgumentError, /can't infer association name for/)
    end
  end

  context 'with Update' do
    let!(:john) do
      user_repo.create(name: 'John')
    end

    let!(:jane) do
      user_repo.create(name: 'Jane')
    end

    let!(:task) do
      task_repo.create(title: 'Test 1', user_id: john.id)
    end

    it 'associates child with parent' do
      changeset = task_repo.changeset(task.id, title: 'Test 2')

      expect(changeset.associate(jane, :user).commit).
        to include(user_id: jane.id, title: 'Test 2')
    end
  end
end
