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

          attribute :name
          attribute :email

          combine :tasks, name: :name do
            attribute :title
          end
        end
      end
    end

    let(:users) { rom.relation(:users) }
    let(:tasks) { rom.relation(:tasks) }

    it 'works' do
      result = users.combine(tasks.for_users) >> rom.mappers.users[:entity]

      expect(result).to match_array([
        { name: 'Joe', email: 'joe@doe.org', tasks: [
          { name: 'Joe', title: 'be nice', priority: 1 },
          { name: 'Joe', title: 'sleep well', priority: 2 } ],
        },
        { name: 'Jane', email: 'jane@doe.org', tasks: [
          { name: 'Jane', title: 'be cool', priority: 2 } ]
        }
      ])
    end
  end
end
