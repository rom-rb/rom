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
          model name: 'ROMSpec::Task'

          attribute :title
          attribute :priority
        end
      end
    end

    it 'allows defining wrapped attributes via options hash' do
      setup.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'ROMSpec::TaskWithUser'

          attribute :title
          attribute :priority

          wrap user: [:email]
        end
      end

      rom = setup.finalize

      ROMSpec::TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))

      jane = rom.read(:tasks).with_user.to_a.last

      expect(jane).to eql(
        ROMSpec::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: { email: 'jane@doe.org' }
        )
      )
    end

    it 'allows defining wrapped attributes via options block' do
      setup.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'ROMSpec::TaskWithUser'

          attribute :title
          attribute :priority

          wrap :user do
            attribute :email
          end
        end
      end

      rom = setup.finalize

      ROMSpec::TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))

      jane = rom.read(:tasks).with_user.to_a.last

      expect(jane).to eql(
        ROMSpec::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: { email: 'jane@doe.org' }
        )
      )
    end

    it 'allows defining nested wrapped attributes via a block' do
      setup.mappers do
        define(:with_user, parent: :tasks, inherit_header: false) do
          model name: 'ROMSpec::TaskWithUser'

          attribute :title
          attribute :priority

          wrap :user do
            model name: 'ROMSpec::TaskUser'
            attribute :name

            wrap :contact do
              model name: 'ROMSpec::Contact'
              attribute :email
            end
          end
        end
      end

      rom = setup.finalize

      ROMSpec::TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))
      ROMSpec::TaskUser.send(:include, Equalizer.new(:name, :contact))
      ROMSpec::Contact.send(:include, Equalizer.new(:email))

      jane = rom.read(:tasks).with_user.to_a.last

      expect(jane).to eql(
        ROMSpec::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: ROMSpec::TaskUser.new(
            name: 'Jane', contact: ROMSpec::Contact.new(email: 'jane@doe.org')
          )
        )
      )
    end

    it 'allows defining wrapped attributes mapped to a model' do
      setup.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'ROMSpec::TaskWithUser'

          attribute :title
          attribute :priority

          wrap :user do
            model name: 'ROMSpec::User'
            attribute :email
          end
        end
      end

      rom = setup.finalize

      ROMSpec::TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))
      ROMSpec::User.send(:include, Equalizer.new(:email))

      jane = rom.read(:tasks).with_user.to_a.last

      expect(jane).to eql(
        ROMSpec::TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: ROMSpec::User.new(email: 'jane@doe.org')
        )
      )
    end
  end
end
