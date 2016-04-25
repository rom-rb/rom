RSpec.shared_context 'relations' do
  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }
  let(:tags) { rom.relation(:tags) }
  let(:posts) { rom.relation(:posts) }

  before do
    configuration.relation(:users) do
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
      def find(criteria)
        where(criteria)
      end

      def for_users(users)
        where(user_id: users.map { |u| u[:id] })
      end
    end

    configuration.relation(:tags)

    configuration.relation(:posts) do
      schema do
        attribute :id, ROM::SQL::Types::Serial
        attribute :author_id, ROM::SQL::Types::ForeignKey(:users)
        attribute :title, ROM::SQL::Types::String
        attribute :body, ROM::SQL::Types::String
      end
    end
  end
end
