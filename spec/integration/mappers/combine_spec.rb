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
          end
        end
      end
    end

    let(:users) { rom.relation(:users) }
    let(:tasks) { rom.relation(:tasks) }

    let(:joe) {
      Test::User.new(name: 'Joe', email: 'joe@doe.org', tasks: [
        Test::Task.new(name: 'Joe', title: 'be nice', priority: 1),
        Test::Task.new(name: 'Joe', title: 'sleep well', priority: 2)
      ])
    }

    let(:jane) {
      Test::User.new(name: 'Jane', email: 'jane@doe.org', tasks: [
        Test::Task.new(name: 'Jane', title: 'be cool', priority: 2)
      ])
    }

    it 'works' do
      rom

      Test::User.send(:include, Equalizer.new(:name, :email, :tasks))
      Test::Task.send(:include, Equalizer.new(:title))

      result = users.combine(tasks.for_users) >> rom.mappers.users[:entity]

      expect(result).to match_array([joe, jane])
    end
  end
end
