require 'spec_helper'

describe 'Mapper definition DSL' do
  include_context 'users and tasks'

  let(:header) { mapper.header }

  describe 'stepped mapper' do
    before do
      setup.relation(:tasks) do
        def with_users
          join(users)
        end
      end

      setup.relation(:users) do
        def with_tasks
          join(tasks)
        end
      end

      setup.mappers do
        define(:users) do
        end
      end
    end

    it 'processes the mapper step by step' do
      setup.mappers do
        define(:with_tasks, parent: :users) do

          step do
            attribute :an_email, from: :email
          end

          step do
            attribute :name
            attribute :title
            attribute :priority
            attribute :email, from: :an_email
          end

          step do
            model name: 'Test::UserWithTasks'
            attribute :name
            attribute :email
            group tasks: [:title, :priority]
          end

        end
      end

      rom = setup.finalize

      Test::UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

      jane = rom.relation(:users).with_tasks.map_with(:with_tasks).to_a.last

      expect(jane.name).to eql('Jane')
      expect(jane.email).to eql('jane@doe.org')
      expect(jane.tasks).to eql([{ title: 'be cool', priority: 2 }])
    end

  end
end
