require 'spec_helper'

RSpec.describe 'Mapper definition DSL' do
  include_context 'container'
  include_context 'users and tasks'

  let(:header) { mapper.header }

  describe 'unwrapping relation mapper' do
    before do
      configuration.relation(:tasks) do
        def with_user
          tuples = map { |tuple|
            tuple.merge(user: users.restrict(name: tuple[:name]).first)
          }

          new(tuples)
        end
      end

      configuration.relation(:users)

      configuration.mappers do
        define(:tasks) do
          model name: 'Test::Task'

          attribute :title
          attribute :priority
        end
      end
    end

    it 'unwraps nested attributes via options hash' do
      configuration.mappers do
        define(:with_user, parent: :tasks) do
          attribute :title
          attribute :priority

          unwrap user: [:email, :name]
        end
      end

      result = container.relations[:tasks].with_user.map_with(:with_user).to_a.last

      expect(result).to eql(title: 'be cool',
                            priority: 2,
                            name: 'Jane',
                            email: 'jane@doe.org')
    end

    it 'unwraps nested attributes via options block' do
      configuration.mappers do
        define(:with_user, parent: :tasks) do
          attribute :title
          attribute :priority

          unwrap :user do
            attribute :name
            attribute :user_email, from: :email
          end
        end
      end

      result = container.relations[:tasks].with_user.map_with(:with_user).to_a.last

      expect(result).to eql(title: 'be cool',
                            priority: 2,
                            name: 'Jane',
                            user_email: 'jane@doe.org')
    end

    it 'unwraps specified attributes via options block' do
      configuration.mappers do
        define(:with_user, parent: :tasks) do
          attribute :title
          attribute :priority

          unwrap :contact, from: :user do
            attribute :task_user_name, from: :name
          end
        end
      end

      result = container.relations[:tasks].with_user.map_with(:with_user).to_a.last

      expect(result).to eql(title: 'be cool',
                            priority: 2,
                            name: 'Jane',
                            task_user_name: 'Jane',
                            contact: { email: 'jane@doe.org' })
    end
  end
end
