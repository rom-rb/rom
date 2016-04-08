RSpec.shared_context 'mappers' do
  let(:users) { rom.relation(:users).mappers[:user] }
  let(:tasks) { rom.relation(:tasks).mappers[:task] }
  let(:tags) { rom.relation(:tags).mappers[:tag] }

  before do
    configuration.mappers do
      define(:users) do
        model Test::Models::User
        register_as :user

        attribute :id
        attribute :name
      end

      define(:tasks) do
        model Test::Models::Task
        register_as :task

        attribute :id
        attribute :user_id
        attribute :title
      end

      define(:tags) do
        model Test::Models::Tag
        register_as :tag

        attribute :id
        attribute :task_id
        attribute :name
      end
    end
  end
end
