shared_context 'command graph' do
  let(:rom) { setup.finalize }
  let(:setup) { ROM.setup(:memory) }

  before do
    setup.relation :users do
      def by_name(name)
        restrict(name: name)
      end
    end

    setup.relation :tasks do
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

    setup.relation :books
    setup.relation :tags

    setup.commands(:users) do
      define(:create) do
        result :one
      end
    end

    setup.commands(:books) do
      define(:create) do
        def execute(tuples, user)
          super(tuples.map { |t| t.merge(user: user.fetch(:name)) })
        end
      end
    end

    setup.commands(:tags) do
      define(:create) do
        def execute(tuples, task)
          super(tuples.map { |t| t.merge(task: task.fetch(:title)) })
        end
      end
    end
  end
end
