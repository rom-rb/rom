require 'spec_helper'
require 'virtus'

describe ROM::Processor::Transproc do
  subject(:transproc) { ROM::Processor::Transproc.build(header) }

  let(:header) { ROM::Header.coerce(attributes, options) }
  let(:options) { {} }

  context 'no mapping' do
    let(:attributes) { [[:name]] }
    let(:relation) { [{ name: 'Jane' }, { name: 'Joe' }] }

    it 'returns tuples' do
      expect(transproc[relation]).to eql(relation)
    end
  end

  context 'coercing values' do
    let(:attributes) { [[:name, type: :string], [:age, type: :integer]] }
    let(:relation) { [{ name: :Jane, age: '1' }, { name: :Joe, age: '2' }] }

    it 'returns tuples' do
      expect(transproc[relation]).to eql([
        { name: 'Jane', age: 1 }, { name: 'Joe', age: 2 }
      ])
    end
  end

  context 'mapping to object' do
    let(:options) { { model: model } }

    let(:model) do
      Class.new do
        include Virtus.value_object
        values { attribute :name }
      end
    end

    let(:attributes) { [[:name]] }
    let(:relation) { [{ name: 'Jane' }, { name: 'Joe' }] }

    it 'returns tuples' do
      expect(transproc[relation]).to eql([
        model.new(name: 'Jane'), model.new(name: 'Joe')
      ])
    end
  end

  context 'renaming keys' do
    let(:attributes) do
      [[:name, from: 'name']]
    end

    let(:options) do
      { reject_keys: true }
    end

    let(:relation) do
      [
        { 'name' => 'Jane', 'age' => 21 }, { 'name' => 'Joe', age: 22 }
      ]
    end

    it 'returns tuples with rejected keys' do
      expect(transproc[relation]).to eql([{ name: 'Jane' }, { name: 'Joe' }])
    end
  end

  describe 'rejecting keys' do
    let(:options) { { reject_keys: true } }

    let(:attributes) do
      [
        ['name'],
        ['tasks', type: :array, group: true, header: [['title']]]
      ]
    end

    let(:relation) do
      [
        { 'name' => 'Jane', 'age' => 21, 'title' => 'Task One' },
        { 'name' => 'Jane', 'age' => 21, 'title' => 'Task Two' },
        { 'name' => 'Joe', 'age' => 22, 'title' => 'Task One' }
      ]
    end

    it 'returns tuples with unknown keys rejected' do
      expect(transproc[relation]).to eql([
        { 'name' => 'Jane',
          'tasks' => [{ 'title' => 'Task One' }, { 'title' => 'Task Two' }] },
        { 'name' => 'Joe',
          'tasks' => [{ 'title' => 'Task One' }] }
      ])
    end
  end

  context 'mapping nested hash' do
    let(:relation) do
      [
        { 'name' => 'Jane', 'task' => { 'title' => 'Task One' } },
        { 'name' => 'Joe', 'task' => { 'title' => 'Task Two' } }
      ]
    end

    context 'when no mapping is needed' do
      let(:attributes) { [['name'], ['task', type: :hash, header: [[:title]]]] }

      it 'returns tuples' do
        expect(transproc[relation]).to eql(relation)
      end
    end

    context 'with deeply nested hashes' do
      context 'when no renaming is required' do
        let(:relation) do
          [
            { 'user' => { 'name' => 'Jane', 'task' => { 'title' => 'Task One' } } },
            { 'user' => { 'name' => 'Joe', 'task' => { 'title' => 'Task Two' } } }
          ]
        end

        let(:attributes) do
          [[
            'user', type: :hash, header: [
              ['name'],
              ['task', type: :hash, header: [['title']]]
            ]
          ]]
        end

        it 'returns tuples' do
          expect(transproc[relation]).to eql(relation)
        end
      end

      context 'when renaming is required' do
        let(:relation) do
          [
            { user: { name: 'Jane', task: { title: 'Task One' } } },
            { user: { name: 'Joe', task: { title: 'Task Two' } } }
          ]
        end

        let(:attributes) do
          [[
            'user', type: :hash, header: [
              ['name'],
              ['task', type: :hash, header: [['title']]]
            ]
          ]]
        end

        it 'returns tuples' do
          expect(transproc[relation]).to eql(relation)
        end
      end
    end

    context 'renaming keys' do
      context 'when only hash needs renaming' do
        let(:attributes) do
          [
            ['name'],
            [:task, from: 'task', type: :hash, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns tuples with key renamed in the nested hash' do
          expect(transproc[relation]).to eql([
            { 'name' => 'Jane', :task => { title: 'Task One' } },
            { 'name' => 'Joe', :task => { title: 'Task Two' } }
          ])
        end
      end

      context 'when all attributes need renaming' do
        let(:attributes) do
          [
            [:name, from: 'name'],
            [:task, from: 'task', type: :hash, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns tuples with key renamed in the nested hash' do
          expect(transproc[relation]).to eql([
            { name: 'Jane', task: { title: 'Task One' } },
            { name: 'Joe', task: { title: 'Task Two' } }
          ])
        end
      end
    end
  end

  context 'wrapping tuples' do
    let(:relation) do
      [
        { 'name' => 'Jane', 'title' => 'Task One' },
        { 'name' => 'Joe', 'title' => 'Task Two' }
      ]
    end

    context 'when no mapping is needed' do
      let(:attributes) do
        [
          ['name'],
          ['task', type: :hash, wrap: true, header: [['title']]]
        ]
      end

      it 'returns wrapped tuples' do
        expect(transproc[relation]).to eql([
          { 'name' => 'Jane', 'task' => { 'title' => 'Task One' } },
          { 'name' => 'Joe', 'task' => { 'title' => 'Task Two' } }
        ])
      end
    end

    context 'with deeply wrapped tuples' do
      let(:attributes) do
        [
          ['user', type: :hash, wrap: true, header: [
            ['name'],
            ['task', type: :hash, wrap: true, header: [['title']]]
          ]]
        ]
      end

      it 'returns wrapped tuples' do
        expect(transproc[relation]).to eql([
          { 'user' => { 'name' => 'Jane', 'task' => { 'title' => 'Task One' } } },
          { 'user' => { 'name' => 'Joe', 'task' => { 'title' => 'Task Two' } } }
        ])
      end
    end

    context 'renaming keys' do
      context 'when only wrapped tuple requires renaming' do
        let(:attributes) do
          [
            ['name'],
            ['task', type: :hash, wrap: true, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns wrapped tuples with renamed keys' do
          expect(transproc[relation]).to eql([
            { 'name' => 'Jane', 'task' => { title: 'Task One' } },
            { 'name' => 'Joe', 'task' => { title: 'Task Two' } }
          ])
        end
      end

      context 'when all attributes require renaming' do
        let(:attributes) do
          [
            [:name, from: 'name'],
            [:task, type: :hash, wrap: true, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns wrapped tuples with all keys renamed' do
          expect(transproc[relation]).to eql([
            { name: 'Jane', task: { title: 'Task One' } },
            { name: 'Joe', task: { title: 'Task Two' } }
          ])
        end
      end
    end
  end

  context 'grouping tuples' do
    let(:relation) do
      [
        { 'name' => 'Jane', 'title' => 'Task One' },
        { 'name' => 'Jane', 'title' => 'Task Two' },
        { 'name' => 'Joe', 'title' => 'Task One' }
      ]
    end

    context 'when no mapping is needed' do
      let(:attributes) do
        [
          ['name'],
          ['tasks', type: :array, group: true, header: [['title']]]
        ]
      end

      it 'returns wrapped tuples with all keys renamed' do
        expect(transproc[relation]).to eql([
          { 'name' => 'Jane',
            'tasks' => [{ 'title' => 'Task One' }, { 'title' => 'Task Two' }] },
          { 'name' => 'Joe',
            'tasks' => [{ 'title' => 'Task One' }] }
        ])
      end
    end

    context 'renaming keys' do
      context 'when only grouped tuple requires renaming' do
        let(:attributes) do
          [
            ['name'],
            ['tasks', type: :array, group: true, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns grouped tuples with renamed keys' do
          expect(transproc[relation]).to eql([
            { 'name' => 'Jane',
              'tasks' => [{ title: 'Task One' }, { title: 'Task Two' }] },
            { 'name' => 'Joe',
              'tasks' => [{ title: 'Task One' }] }
          ])
        end
      end

      context 'when all attributes require renaming' do
        let(:attributes) do
          [
            [:name, from: 'name'],
            [:tasks, type: :array, group: true, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns grouped tuples with all keys renamed' do
          expect(transproc[relation]).to eql([
            { name: 'Jane',
              tasks: [{ title: 'Task One' }, { title: 'Task Two' }] },
            { name: 'Joe',
              tasks: [{ title: 'Task One' }] }
          ])
        end
      end
    end

    context 'nested grouping' do
      let(:relation) do
        [
          { name: 'Jane', title: 'Task One', tag: 'red' },
          { name: 'Jane', title: 'Task One', tag: 'green' },
          { name: 'Joe', title: 'Task One', tag: 'blue' }
        ]
      end

      let(:attributes) do
        [
          [:name],
          [:tasks, type: :array, group: true, header: [
            [:title],
            [:tags, type: :array, group: true, header: [[:tag]]]
          ]]
        ]
      end

      it 'returns deeply grouped tuples' do
        expect(transproc[relation]).to eql([
          { name: 'Jane',
            tasks: [
              { title: 'Task One', tags: [{ tag: 'red' }, { tag: 'green' }] }
            ]
          },
          { name: 'Joe',
            tasks: [
              { title: 'Task One', tags: [{ tag: 'blue' }] }
            ]
          }
        ])
      end
    end
  end
end
