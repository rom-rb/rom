require 'spec_helper'

describe 'Mapper definition DSL' do
  let(:setup) { ROM.setup(:memory) }
  let(:rom)   { ROM.finalize.env   }

  before do
    setup.relation(:lists)

    setup.default.dataset(:lists).insert(
      list_id: 1,
      list_tasks: [
        { user: 'Jacob', task_id: 1, task_title: 'be nice'    },
        { user: 'Jacob', task_id: 2, task_title: 'sleep well' }
      ]
    )
  end

  describe 'step' do
    let(:mapped) { rom.relation(:lists).as(:lists).to_a }

    it 'applies transformations one by one' do
      setup.mappers do
        define(:lists) do
          step do
            prefix 'list'
            attribute :id
            unfold :tasks
          end

          step do
            unwrap :tasks do
              attribute :task_id
              attribute :name, from: :user
              attribute :task_title
            end
          end

          step do
            group :tasks do
              prefix 'task'
              attribute :id
              attribute :title
            end
          end

          step do
            wrap :user do
              attribute :name
              attribute :tasks
            end
          end
        end
      end

      expect(mapped).to eql [
        {
          id: 1,
          user: {
            name: 'Jacob',
            tasks: [
              { id: 1, title: 'be nice'    },
              { id: 2, title: 'sleep well' }
            ]
          }
        }
      ]
    end

    it 'applies settings from root' do
      setup.mappers do
        define(:lists) do

          prefix 'list'

          step do
            attribute :id
            attribute :tasks
          end
        end
      end

      expect(mapped).to eql [
        {
          id: 1,
          tasks: [
            { user: 'Jacob', task_id: 1, task_title: 'be nice'    },
            { user: 'Jacob', task_id: 2, task_title: 'sleep well' }
          ]
        }
      ]
    end

    it 'cannot precede attributes' do
      setup.mappers do
        define(:lists) do
          step do
            unfold :tasks, from: :list_tasks
          end
          attribute :id, from: :list_id
        end
      end

      expect { rom }.to raise_error ROM::MapperMisconfiguredError
    end

    it 'cannot succeed attributes' do
      setup.mappers do
        define(:lists) do
          attribute :id, from: :list_id
          step do
            unfold :tasks, from: :list_tasks
          end
        end
      end

      expect { rom }.to raise_error ROM::MapperMisconfiguredError
    end
  end
end
