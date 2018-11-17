require 'spec_helper'

RSpec.describe 'Mapper definition DSL' do
  include_context 'container'
  include_context 'users and tasks'

  let(:header) { mapper.header }

  describe 'wrapped relation mapper' do
    before do
      configuration.relation(:tasks) do
        def with_user
          join(users)
        end
      end

      configuration.relation(:users)

      configuration.mappers do
        define(:tasks) do
          model name: 'Test::Task'

          attribute :title
          attribute :priority
        end
      end
    end

    it 'allows defining wrapped attributes via options hash' do
      configuration.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'Test::TaskWithUser'

          attribute :title
          attribute :priority

          wrap user: [:email]
        end
      end

      container

      Test::TaskWithUser.send(:include, Dry::Equalizer(:title, :priority, :user))

      jane = container.relations[:tasks].with_user.map_with(:with_user).to_a.last

      expect(jane).to eql(
        Test::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: { email: 'jane@doe.org' }
        )
      )
    end

    it 'allows defining wrapped attributes via options block' do
      configuration.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'Test::TaskWithUser'

          attribute :title
          attribute :priority

          wrap :user do
            attribute :email
          end
        end
      end

      container

      Test::TaskWithUser.send(:include, Dry::Equalizer(:title, :priority, :user))

      jane = container.relations[:tasks].with_user.map_with(:with_user).to_a.last

      expect(jane).to eql(
        Test::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: { email: 'jane@doe.org' }
        )
      )
    end

    it 'allows defining nested wrapped attributes via a block' do
      configuration.mappers do
        define(:with_user, parent: :tasks, inherit_header: false) do
          model name: 'Test::TaskWithUser'

          attribute :title
          attribute :priority

          wrap :user do
            model name: 'Test::TaskUser'
            attribute :name

            wrap :contact do
              model name: 'Test::Contact'
              attribute :email
            end
          end
        end
      end

      container

      Test::TaskWithUser.send(:include, Dry::Equalizer(:title, :priority, :user))
      Test::TaskUser.send(:include, Dry::Equalizer(:name, :contact))
      Test::Contact.send(:include, Dry::Equalizer(:email))

      jane = container.relations[:tasks].with_user.map_with(:with_user).to_a.last

      expect(jane).to eql(
        Test::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: Test::TaskUser.new(
            name: 'Jane', contact: Test::Contact.new(email: 'jane@doe.org')
          )
        )
      )
    end

    it 'allows defining wrapped attributes mapped to a model' do
      configuration.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'Test::TaskWithUser'

          attribute :title
          attribute :priority

          wrap :user do
            model name: 'Test::User'
            attribute :email
          end
        end
      end

      container

      Test::TaskWithUser.send(:include, Dry::Equalizer(:title, :priority, :user))
      Test::User.send(:include, Dry::Equalizer(:email))

      jane = container.relations[:tasks].with_user.map_with(:with_user).to_a.last

      expect(jane).to eql(
        Test::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: Test::User.new(email: 'jane@doe.org')
        )
      )
    end
  end
end
