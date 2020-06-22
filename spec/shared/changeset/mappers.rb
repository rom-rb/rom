# frozen_string_literal: true

RSpec.shared_context 'changeset / mappers' do
  let(:user_mappers) { users.mappers[:user] }
  let(:task_mappers) { tasks.mappers[:task] }
  let(:tag_mappers) { tags.mappers[:tag] }

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
