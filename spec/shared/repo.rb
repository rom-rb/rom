RSpec.shared_context('repo') do
  let(:repo) { repo_class.new(rom) }

  let(:repo_class) do
    Class.new(ROM::Repository::Base) do
      relations :users, :tasks, :tags

      def find_users(criteria)
        users.find(criteria)
      end

      def all_users
        users.all
      end

      def task_with_user
        combine_parents(tasks.find(id: 2), one: { owner: users })
      end

      def users_with_tasks
        combine_children(users, many: { all_tasks: tasks.for_users })
      end

      def users_with_tasks_and_tags
        combine_children(
          users,
          many: { all_tasks: tasks_with_tags(tasks.for_users) }
        )
      end

      def tasks_with_tags(tasks = self.tasks)
        combine_children(tasks, many: { tags: tags })
      end

      def users_with_task
        combine_children(users, one: { task: tasks })
      end

      def users_with_task_by_title(title)
        combine_children(users, one: { task: tasks.find(title: title) })
      end

      def tag_with_wrapped_task
        wrap_parent(tags, task: tasks)
      end
    end
  end
end
