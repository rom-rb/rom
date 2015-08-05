RSpec.shared_context 'relations' do
  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }
  let(:tags) { rom.relation(:tags) }

  before do
    setup.relation(:users) do
      def all
        select(:id, :name).order(:name, :id)
      end

      def find(criteria)
        where(criteria)
      end
    end

    setup.relation(:tasks) do
      def find(criteria)
        where(criteria)
      end

      def for_users(users)
        where(user_id: users.map { |u| u[:id] })
      end
    end

    setup.relation(:tags)
  end
end
