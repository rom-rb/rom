# encoding: utf-8

shared_context 'Relation' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:header) {
    Axiom::Relation::Header.coerce([[:id, Integer], [:name, String]], keys: [:id])
  }

  let(:users) {
    Axiom::Relation.new(header, [
      [1, 'John'], [2, 'Jane'], [3, 'Jack'], [4, 'Jade']
    ])
  }

  let(:model)  { mock_model(:id, :name) }
  let(:mapper) { TestMapper.new(users.header, model) }

  let(:john) { model.new(id: 1, name: 'John') }
  let(:jane) { model.new(id: 2, name: 'Jane') }
  let(:jack) { model.new(id: 3, name: 'Jack') }
  let(:jade) { model.new(id: 4, name: 'Jade') }
end

shared_context 'Project with tasks' do
  subject(:relation) { described_class.new(projects_with_tasks, mapper) }

  let(:header) {
    Axiom::Relation::Header.coerce(
      [
        [:id,        Integer],
        [:name,      String ],
        [:task_id,   Integer],
        [:task_name, String ],
      ]
    )
  }

  let(:projects_with_tasks) {
    Axiom::Relation.new(header, [
      [1, 'rom-relation', 1, 'Add ROM::Relation#group'  ],
      [1, 'rom-relation', 2, 'Add ROM::Relation#ungroup'],
    ])
  }

  let(:project_with_tasks_model) { mock_model(:id, :name, :tasks) }
  let(:task_model)               { mock_model(:task_id, :task_name) }

  let(:mapper) { ProjectWithTasksMapper.new(header, project_with_tasks_model, task_model) }

  let(:project_with_tasks) {
    project_with_tasks_model.new(id: 1, name: 'rom-relation', tasks: tasks)
  }

  let(:tasks) {[
    # TODO add renaming support: [[:id, Integer], [:name, String]]
    task_model.new(task_id: 1, task_name: 'Add ROM::Relation#group'),
    task_model.new(task_id: 2, task_name: 'Add ROM::Relation#ungroup')
  ]}
end

shared_context 'City with location' do
  subject(:relation) { described_class.new(city_relation, mapper) }

  let(:header) {
    Axiom::Relation::Header.coerce([
      [:id, Integer], [:name, String], [:location_id, Integer], [:lat, Float], [:lng, Float]
    ])
  }

  let(:city_relation) {
    Axiom::Relation.new(header, [[1, 'Krakow', 1, 2.0, 3.0]])
  }

  let(:city_model) { mock_model(:id, :name, :location) }
  let(:location_model) { mock_model(:lat, :lng) }

  let(:mapper) { CityWithLocationMapper.new(header, city_model, location_model) }

  let(:city) { city_model.new(id: 1, name: 'Krakow', location: location) }
  let(:location) { location_model.new(lat: 2.0, lng: 3.0) }
end
