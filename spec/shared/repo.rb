RSpec.shared_context('repo') do
  include_context 'models'
  include_context 'mappers'

  let(:repo) { repo_class.new(rom) }

  let(:repo_class) do
    Class.new(ROM::Repository[:users]) do
      relations :tasks, :tags, :posts, :labels

      def find_users(criteria)
        users.find(criteria)
      end

      def all_users
        users.all
      end

      def all_users_as_users
        users.as(:user).all
      end

      def users_with_tasks
        aggregate(many: { all_tasks: tasks.for_users })
      end

      def users_with_tasks_and_tags
        aggregate(many: { all_tasks: tasks_with_tags(tasks.for_users) })
      end

      def users_with_task
        aggregate(one: tasks)
      end

      def users_with_task_by_title(title)
        aggregate(one: tasks.find(title: title))
      end

      def tasks_for_users(users)
        tasks.for_users(users)
      end

      def task_with_user
        tasks.find(id: 2).combine_parents(one: users)
      end

      def task_with_owner
        tasks.find(id: 2).combine_parents(one: { owner: users })
      end

      def tasks_with_tags(tasks = self.tasks)
        tasks.combine_children(many: tags)
      end

      def tag_with_wrapped_task
        tags.wrap_parent(task: tasks)
      end
    end
  end
end
