# frozen_string_literal: true

RSpec.shared_context "changeset / repo" do
  include_context "changeset / models"
  include_context "changeset / mappers"

  let(:repo) { repo_class.new(rom) }

  let(:repo_class) do
    Class.new(ROM::Repository[:users]) do
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
        aggregate(many: {all_tasks: tasks.for_users})
      end

      def users_with_tasks_and_tags
        aggregate(many: {all_tasks: tasks_with_tags(tasks.for_users)})
      end

      def users_with_task
        aggregate(one: tasks)
      end

      def users_with_task_by_title(title)
        aggregate(one: tasks.find(title: title))
      end

      def users_with_posts_and_their_labels
        users.combine(posts: [:labels])
      end

      def posts_with_labels
        posts.combine_children(many: labels)
      end

      def label_with_posts
        labels.combine_children(one: posts)
      end

      def tasks_for_users(users)
        tasks.for_users(users)
      end

      def task_with_user
        tasks.find(tasks[:id].qualified => 2).wrap_parent(user: users)
      end

      def task_with_owner
        tasks.find(id: 2).combine_parents(one: {owner: users})
      end

      def tasks_with_tags(tasks = self.tasks)
        tasks.combine_children(many: tags)
      end

      def tag_with_wrapped_task
        tags.wrap_parent(task: tasks)
      end
    end
  end

  let(:comments_repo) do
    Class.new(ROM::Repository[:comments]) do
      def comments_with_likes
        aggregate(many: {likes: likes})
      end

      def comments_with_emotions
        root.combine(:emotions)
      end
    end.new(rom)
  end
end
