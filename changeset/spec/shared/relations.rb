# frozen_string_literal: true

RSpec.shared_context 'relations' do
  let(:users) { rom.relations[:users].with(auto_struct: true) }
  let(:tasks) { rom.relations[:tasks].with(auto_struct: true) }
  let(:tags) { rom.relations[:tags].with(auto_struct: true) }
  let(:posts) { rom.relations[:posts].with(auto_struct: true) }
  let(:books) { rom.relations[:books].with(auto_struct: true) }

  before do
    configuration.relation(:books) do
      schema(:books) do
        attribute :id, ROM::SQL::Types::Serial
        attribute :author_id, ROM::SQL::Types.ForeignKey(:users)
        attribute :title, ROM::SQL::Types::String
        attribute :created_at, ROM::SQL::Types::Time
        attribute :updated_at, ROM::SQL::Types::Time

        associations do
          belongs_to :users, as: :author, relation: :authors, foreign_key: :author_id
        end
      end
    end

    configuration.relation(:users) do
      schema(infer: true) do
        associations do
          has_many :posts
          has_many :posts, as: :aliased_posts
          has_many :labels, through: :posts
          has_many :books, foreign_key: :author_id
        end
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

    configuration.relation(:authors) do
      schema(:users, infer: true)
    end

    configuration.relation(:tasks) do
      schema(infer: true) do
        associations do
          belongs_to :user
        end
      end

      def find(criteria)
        where(criteria)
      end

      def for_users(users)
        where(user_id: users.map { |u| u[:id] })
      end
    end

    configuration.relation(:tags) do
      schema(infer: true)
    end

    configuration.relation(:labels) do
      schema(infer: true) do
        associations do
          has_many :posts_labels
          has_many :posts, through: :posts_labels
        end
      end
    end

    configuration.relation(:posts) do
      schema(:posts, infer: true) do
        associations do
          has_many :labels, through: :posts_labels
          belongs_to :user, as: :author
        end
      end
    end

    configuration.relation(:posts_labels) do
      schema(infer: true) do
        associations do
          belongs_to :post
          belongs_to :label
        end
      end
    end

    configuration.relation(:comments) do
      schema(:messages, as: :comments, infer: true) do
        associations do
          has_many :reactions, relation: :likes
          has_many :reactions, relation: :likes, as: :emotions
        end
      end
    end

    configuration.relation(:likes) do
      schema(:reactions, as: :likes, infer: true) do
        associations do
          belongs_to :message, relation: :comments
        end
      end
    end
  end
end
