# frozen_string_literal: true

RSpec.shared_context('repo') do
  include_context 'models'
  include_context 'mappers'

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
        users.map_with(:user).all
      end

      def users_with_posts_and_their_labels
        users.combine(posts: [:labels])
      end

      def posts_with_labels
        posts.combine(:labels)
      end

      def label_with_posts
        labels.combine(:post)
      end

      def task_with_owner
        tasks.find(id: 2).combine(:owner)
      end

      def task_with_user
        tasks.find(id: 2).combine(:user)
      end

      def tasks_with_tags(tasks = self.tasks)
        tasks.combine(:tags)
      end

      def tag_with_wrapped_task
        tags.wrap(:task)
      end
    end
  end

  let(:comments_repo) do
    Class.new(ROM::Repository[:comments]) do
      def comments_with_likes
        comments.combine(:likes)
      end

      def comments_with_emotions
        root.combine(:emotions)
      end
    end.new(rom)
  end
end
