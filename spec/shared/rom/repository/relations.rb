# frozen_string_literal: true

RSpec.shared_context "relations" do
  let(:users) { rom.relations[:users] }
  let(:tasks) { rom.relations[:tasks] }
  let(:tags) { rom.relations[:tags] }
  let(:posts) { rom.relations[:posts] }
  let(:books) { rom.relations[:books] }
  let(:labels) { rom.relations[:labels] }

  before do
    configuration.relation(:books) do
      schema do
        attribute :id, ROM::SQL::Types::Serial
        attribute :author_id, ROM::SQL::Types.ForeignKey(:users)
        attribute :title, ROM::SQL::Types::String
        attribute :created_at, ROM::SQL::Types::Time
        attribute :updated_at, ROM::SQL::Types::Time
      end

      associations do
        belongs_to :users, as: :author, relation: :authors, foreign_key: :author_id
      end

      def expired(expiration_time = Time.now)
        where { created_at < expiration_time }
      end

      def by_author_id_and_title(author_id, title)
        where(author_id: author_id, title: title)
      end
    end

    configuration.relation(:users) do
      schema(infer: true)

      associations do
        has_many :posts
        has_many :posts, as: :aliased_posts
        has_many :labels, through: :posts
        has_many :books, foreign_key: :author_id
        has_many :tasks
        has_one :task
      end

      def by_name(name)
        where(name: name)
      end

      def all
        select(:id, :name).order(:name, :id)
      end

      def find(criteria)
        where(criteria)
      end
    end

    configuration.relation(:authors, dataset: :users) do
      schema(infer: true)
    end

    configuration.relation(:tasks) do
      schema(:tasks, infer: true)

      associations do
        belongs_to :user
        belongs_to :users, as: :assignee
        has_many :tags
        has_one :tag
      end

      def find(criteria)
        where(criteria)
      end

      def for_users(users)
        where(user_id: users.map { |u| u[:id] })
      end
    end

    configuration.relation(:tags) do
      schema(:tags, infer: true)

      associations do
        belongs_to :tasks, as: :task
      end
    end

    configuration.relation(:labels) do
      schema(:labels, infer: true)

      associations do
        has_many :posts_labels
        has_many :posts, through: :posts_labels
      end
    end

    configuration.relation(:posts) do
      schema(:posts, infer: true)

      associations do
        has_many :labels, through: :posts_labels
        belongs_to :user, as: :author
        belongs_to :users
      end
    end

    configuration.relation(:posts_labels) do
      schema(:posts_labels, infer: true)

      associations do
        belongs_to :post
        belongs_to :label
      end
    end

    configuration.relation(:comments) do
      schema(:messages, infer: true)

      associations do
        has_many :reactions, relation: :likes
        has_many :reactions, relation: :likes, as: :emotions
      end
    end

    configuration.relation(:likes) do
      schema(:reactions, infer: true)

      associations do
        belongs_to :messages, as: :message, relation: :comments
        belongs_to :messages, as: :comment, relation: :comments
      end
    end
  end
end
