require 'spec_helper'

describe 'Mapper definition DSL' do
  include_context 'users and tasks'

  describe 'combine' do
    before do
      setup.relation(:tasks) do
        def for_users(users)
          names = users.map { |user| user[:name] }
          restrict { |task| names.include?(task[:name]) }
        end

        def tags(_tasks)
          [{ name: 'blue', task: 'be cool' }]
        end
      end

      setup.relation(:users)

      setup.mappers do
        define(:users) do
          register_as :entity

          model name: 'Test::User'

          attribute :name
          attribute :email

          combine :tasks, name: :name do
            model name: 'Test::Task'

            attribute :title

            wrap :meta do
              attribute :user, from: :name
              attribute :priority
            end

            combine :tags, title: :task do
              model name: 'Test::Tag'

              attribute :name
            end
          end
        end
      end
    end

    let(:users) { rom.relation(:users) }
    let(:tasks) { rom.relation(:tasks) }

    let(:joe) {
      Test::User.new(name: 'Joe', email: 'joe@doe.org', tasks: [
        Test::Task.new(title: 'be nice', meta: { user: 'Joe', priority: 1 }, tags: []),
        Test::Task.new(title: 'sleep well', meta: { user: 'Joe', priority: 2 }, tags: [])
      ])
    }

    let(:jane) {
      Test::User.new(name: 'Jane', email: 'jane@doe.org', tasks: [
        Test::Task.new(
          title: 'be cool',
          meta: { user: 'Jane', priority: 2 },
          tags: [Test::Tag.new(name: 'blue')]
        )
      ])
    }

    it 'works' do
      rom

      Test::User.send(:include, Equalizer.new(:name, :email, :tasks))
      Test::Task.send(:include, Equalizer.new(:title, :meta))

      result = users.as(:entity).combine(tasks.for_users.combine(tasks.tags))

      expect(result).to match_array([joe, jane])
    end
  end
end
