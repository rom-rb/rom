RSpec.shared_context 'relations' do
  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }
  let(:tags) { rom.relation(:tags) }
  let(:posts) { rom.relation(:posts) }
  let(:books) { rom.relation(:books) }

  before do
    configuration.relation(:books) do
      schema(:books) do
        attribute :id, ROM::SQL::Types::Serial
        attribute :title, ROM::SQL::Types::String
        attribute :created_at, ROM::SQL::Types::Time
        attribute :updated_at, ROM::SQL::Types::Time
      end

      def by_id(id)
        where(id: id)
      end
    end

    configuration.relation(:users) do
      schema(:users) do
        attribute :id, ROM::SQL::Types::Serial
        attribute :name, ROM::SQL::Types::String

        associations do
          has_many :posts
          has_many :labels, through: :posts
        end
      end

      def by_id(id)
        where(id: id)
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

    configuration.relation(:tasks) do
      schema do
        attribute :id, ROM::SQL::Types::Serial
        attribute :user_id, ROM::SQL::Types::ForeignKey(:users)
        attribute :title, ROM::SQL::Types::String

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

    configuration.relation(:tags)
    configuration.relation(:labels)

    configuration.relation(:posts) do
      schema(:posts) do
        attribute :id, ROM::SQL::Types::Serial
        attribute :author_id, ROM::SQL::Types::ForeignKey(:users)
        attribute :title, ROM::SQL::Types::String
        attribute :body, ROM::SQL::Types::String

        associations do
          has_many :labels, through: :posts_labels
          belongs_to :user, as: :author
        end
      end
    end

    configuration.relation(:posts_labels) do
      schema do
        attribute :post_id, ROM::SQL::Types::ForeignKey(:posts)
        attribute :label_id, ROM::SQL::Types::ForeignKey(:labels)
        primary_key :post_id, :label_id

        associations do
          belongs_to :post
          belongs_to :label
        end
      end
    end

    configuration.relation(:comments) do
      register_as :comments

      schema(:messages) do
        attribute :message_id, ROM::SQL::Types::Serial
        attribute :author, ROM::SQL::Types::String
        attribute :body, ROM::SQL::Types::String

        associations do
          has_many :reactions, relation: :likes
          has_many :reactions, relation: :likes, as: :emotions
        end
      end
    end

    configuration.relation(:likes) do
      register_as :likes

      schema(:reactions) do
        attribute :reaction_id, ROM::SQL::Types::Serial
        attribute :message_id, ROM::SQL::Types::ForeignKey(:messages)
        attribute :author, ROM::SQL::Types::String

        associations do
          belongs_to :message, relation: :comments
        end
      end
    end
  end
end
