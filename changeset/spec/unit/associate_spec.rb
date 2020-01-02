RSpec.describe ROM::Changeset, '#associate' do
  include_context 'database setup'

  let(:people) do
    rom.relations[:people].with(auto_struct: true)
  end

  let(:todos) do
    rom.relations[:todos].with(auto_struct: true)
  end

  let(:projects) do
    rom.relations[:projects].with(auto_struct: true)
  end

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
      schema(:people, infer: true) do
        associations do
          has_many :todos
        end
      end
    end

    configuration.relation(:projects) do
      schema(:projects, infer: true) do
        associations do
          has_many :todos
        end
      end
    end

    configuration.relation(:todos) do
      schema(:todos, infer: true) do
        associations do
          belongs_to :people, as: :user
          belongs_to :project
        end
      end
    end
  end

  context 'with Create' do
    let(:jane) do
      people.command(:create).call(name: 'Jane')
    end

    let(:project) do
      projects.command(:create).call(name: 'rom-rb')
    end

    it 'associates child with parent' do
      changeset = todos.changeset(:create, title: 'Test 1').associate(jane)

      expect(changeset.commit.to_h).to include(user_id: jane.id, title: 'Test 1')
    end

    it 'associates child with multiple parents' do
      changeset = todos.changeset(:create, title: 'Test 1')
        .associate(jane, :user)
        .associate(project)

      expect(changeset.commit.to_h)
        .to include(user_id: jane.id, project_id: project.id, title: 'Test 1')
    end

    it 'associates multiple children with a parent' do
      pending 'This is not implemented yet'

      project_todos = [
        { user_id: jane.id, title: 'Test 1' },
        { user_id: jane.id, title: 'Test 2' }
      ]

      changeset = projects.changeset(:create, name: 'rom-rb')
        .associate(project_todos, :project)

      result = changeset.commit

      expect(result).to include(name: 'rom-rb')
      expect(result[:todos].size).to be(2)
    end

    it 'raises when assoc name cannot be inferred' do
      other = Class.new do
        def self.schema
          []
        end
      end.new

      expect { todos.changeset(:create, title: 'Test 1').associate(other) }
        .to raise_error(ArgumentError, /can't infer association name for/)
    end
  end

  context 'with Update' do
    let!(:john) do
      people.command(:create).call(name: 'John')
    end

    let!(:jane) do
      people.command(:create).call(name: 'Jane')
    end

    let!(:todo) do
      todos.command(:create).call(title: 'Test 1', user_id: john.id)
    end

    it 'associates child with parent' do
      changeset = todos.by_pk(todo.id).changeset(:update, title: 'Test 2')

      expect(changeset.associate(jane).commit.to_h)
        .to include(user_id: jane.id, title: 'Test 2')
    end
  end
end
