# frozen_string_literal: true

RSpec.shared_context "mappers" do
  let(:user_mappers) { users.mappers[:user] }
  let(:task_mappers) { tasks.mappers[:task] }
  let(:tag_mappers) { tags.mappers[:tag] }

  before do
    configuration.mappers do
      define(:users) do
        model Test::Models::User
        config.component.id = :user

        attribute :id
        attribute :name
      end

      define(:tasks) do
        model Test::Models::Task
        config.component.id = :task

        attribute :id
        attribute :user_id
        attribute :title
      end

      define(:tags) do
        model Test::Models::Tag
        config.component.id = :tag

        attribute :id
        attribute :task_id
        attribute :name
      end
    end
  end
end
