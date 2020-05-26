# frozen_string_literal: true

RSpec.shared_context 'command graph' do
  include_context 'container'

  before do
    configuration.relation :users do
      def by_name(name)
        restrict(name: name)
      end
    end

    configuration.relation :tasks do
      def by_user_and_title(user, title)
        by_user(user).by_title(title)
      end

      def by_user(user)
        restrict(user: user)
      end

      def by_title(title)
        restrict(title: title)
      end
    end

    configuration.relation :books
    configuration.relation :tags

    configuration.commands(:users) do
      define(:create) do
        result :one
      end
    end

    configuration.commands(:books) do
      define(:create) do
        before :associate

        def associate(tuples, user)
          tuples.map { |t| t.merge(user: user.fetch(:name)) }
        end
      end
    end

    configuration.commands(:tags) do
      define(:create) do
        before :associate

        def associate(tuples, task)
          tuples.map { |t| t.merge(task: task.fetch(:title)) }
        end
      end
    end
  end
end
