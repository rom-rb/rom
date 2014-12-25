require 'spec_helper'

require 'ostruct'

describe ROM::Header::Attribute do
  describe 'embedded hash transformation' do
    subject(:attribute) do
      ROM::Header::Attribute.coerce([
        :task,
        transform: true,
        type: Hash,
        header: [[:title, from: 'title']]
      ])
    end

    it 'renames attribute and wraps header keys' do
      transformation = attribute.to_transproc

      input = [{ 'title' => 'Task' }]
      output = [{ task: { title: 'Task' } }]

      expect(transformation[input]).to eql(output)
    end
  end

  describe 'embedded array transformation' do
    subject(:attribute) do
      ROM::Header::Attribute.coerce([
        :tasks,
        transform: true,
        type: Array,
        header: [[:title, from: 'title']]
      ])
    end

    it 'renames attribute and groups header keys' do
      transformation = attribute.to_transproc

      input = [{ 'title' => 'Task One' }, { 'title' => 'Task Two' }]
      output = [{ tasks: [{ title: 'Task One' }, { title: 'Task Two' }] }]

      expect(transformation[input]).to eql(output)
    end
  end

  describe 'embedded hash transformation' do
    subject(:attribute) do
      ROM::Header::Attribute.coerce([
        :task,
        transform: true,
        type: Hash,
        header: [[:title, from: 'title']]
      ])
    end

    it 'renames attribute and wraps header keys' do
      transformation = attribute.to_transproc

      input = [{ 'title' => 'Task One' }, { 'title' => 'Task Two' }]
      output = [{ task: { title: 'Task One' } }, { task: { title: 'Task Two' } }]

      expect(transformation[input]).to eql(output)
    end
  end

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
          transform: true,
          type: Hash,
          model: task_model,
          header: [[:title, from: 'title']]
        ])
      end

      it 'renames attribute and builds objects from wraped tuples' do
        transformation = attribute.to_transproc

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
          transform: true,
          type: Array,
          model: task_model,
          header: [[:title, from: 'title']]
        ])
      end

      it 'renames attribute and builds objects from wraped tuples' do
        transformation = attribute.to_transproc

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
