require 'spec_helper'

describe ROM::Header::Attribute do
  describe 'building model instance from tuples' do
    let(:task_model) do
      Class.new do
        include Virtus.value_object
        values { attribute :title }
      end
    end

    context 'with wrap transformation' do
      subject(:attribute) do
        ROM::Header::Attribute.coerce([
          :task,
          wrap: true,
          type: Hash,
          model: task_model,
          header: [[:title, from: 'title']]
        ])
      end

      it 'renames attribute and builds objects from wraped tuples' do
        transformation = attribute.preprocessor + Transproc(:map_array, attribute.to_transproc)

        input = [{ 'title' => 'Task One' }, { 'title' => 'Task Two' }]

        output = [
          { task: task_model.new(title: 'Task One') },
          { task: task_model.new(title: 'Task Two') }
        ]

        expect(transformation[input]).to eql(output)
      end
    end

    context 'with group transformation' do
      subject(:attribute) do
        ROM::Header::Attribute.coerce([
          :tasks,
          group: true,
          type: Array,
          model: task_model,
          header: [[:title, from: 'title']]
        ])
      end

      it 'renames attribute and builds objects from grouped tuples' do
        transformation = attribute.preprocessor + Transproc(:map_array, attribute.to_transproc)

        input = [{ 'title' => 'Task One' }, { 'title' => 'Task Two' }]

        output = [{
          tasks: [
            task_model.new(title: 'Task One'),
            task_model.new(title: 'Task Two')
          ]}
        ]

        expect(transformation[input]).to eql(output)
      end
    end
  end
end
