# frozen_string_literal: true

RSpec.shared_context 'changeset / models' do
  let(:user_model) { Test::Models::User }
  let(:task_model) { Test::Models::Task }
  let(:tag_model) { Test::Models::Tag }

  before do
    module Test
      module Models
        class User
          include Dry::Equalizer(:id, :name)

          attr_reader :id, :name

          def initialize(attrs)
            @id = attrs[:id]
            @name = attrs[:name]
          end
        end

        class Task
          include Dry::Equalizer(:id, :user_id, :title)

          attr_reader :id, :user_id, :title

          def initialize(attrs)
            @id = attrs[:id]
            @name = attrs[:name]
            @title = attrs[:title]
          end
        end

        class Tag
          include Dry::Equalizer(:id, :task_id, :name)

          attr_reader :id, :task_id, :name

          def initialize(attrs)
            @id = attrs[:id]
            @task_id = attrs[:task_id]
            @name = attrs[:name]
          end
        end
      end
    end
  end
end
