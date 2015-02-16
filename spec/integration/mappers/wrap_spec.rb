require 'spec_helper'

describe 'Mapper definition DSL' do
  include_context 'users and tasks'

  let(:header) { mapper.header }

  describe 'wrapped relation mapper' do
    before do
      setup.relation(:tasks) do
        def with_user
          join(users)
        end
      end

      setup.relation(:users)

      setup.mappers do
        define(:tasks) do
          model name: 'Test::Task'

          attribute :title
          attribute :priority
        end
      end
    end

    it 'allows defining wrapped attributes via options hash' do
      setup.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'Test::TaskWithUser'

          attribute :title
          attribute :priority

          wrap user: [:email]
        end
      end

      rom = setup.finalize

      Test::TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))

      jane = rom.read(:tasks).with_user.to_a.last

      expect(jane).to eql(
        Test::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: { email: 'jane@doe.org' }
        )
      )
    end

    it 'allows defining wrapped attributes via options block' do
      setup.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'Test::TaskWithUser'

          attribute :title
          attribute :priority

          wrap :user do
            attribute :email
          end
        end
      end

      rom = setup.finalize

      Test::TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))

      jane = rom.read(:tasks).with_user.to_a.last

      expect(jane).to eql(
        Test::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: { email: 'jane@doe.org' }
        )
      )
    end

    it 'allows defining nested wrapped attributes via a block' do
      setup.mappers do
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

      rom = setup.finalize

      Test::TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))
      Test::TaskUser.send(:include, Equalizer.new(:name, :contact))
      Test::Contact.send(:include, Equalizer.new(:email))

      jane = rom.read(:tasks).with_user.to_a.last

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
      setup.mappers do
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

      rom = setup.finalize

      Test::TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))
      Test::User.send(:include, Equalizer.new(:email))

      jane = rom.read(:tasks).with_user.to_a.last

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
