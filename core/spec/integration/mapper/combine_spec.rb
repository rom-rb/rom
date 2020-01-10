# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mapper definition DSL' do
  include_context 'container'
  include_context 'users and tasks'

  describe 'combine' do
    before do
      configuration.relation(:tasks) do
        auto_map false

        schema(:tasks) {}

        def for_users(users)
          names = users.map { |user| user[:name] }
          restrict { |task| names.include?(task[:name]) }
        end

        def tags(_tasks)
          [{ name: 'blue', task: 'be cool' }]
        end
      end

      configuration.relation(:users) do
        auto_map false

        schema(:users) {}

        def addresses(_users)
          [{ city: 'NYC', user: 'Jane' }, { city: 'Boston', user: 'Joe' }]
        end

        def books(_users)
          [{ title: 'Book One', user: 'Jane' }, { title: 'Book Two', user: 'Joe' }]
        end
      end

      configuration.mappers do
        define(:users) do
          register_as :entity

          model name: 'Test::User'

          attribute :name
          attribute :email

          combine :tasks, on: { name: :name } do
            model name: 'Test::Task'

            attribute :title

            wrap :meta do
              attribute :user, from: :name
              attribute :priority
            end

            combine :tags, on: { title: :task } do
              model name: 'Test::Tag'

              attribute :name
            end
          end

          combine :address, on: { name: :user }, type: :hash do
            model name: 'Test::Address'

            attribute :city
          end

          combine :book, on: { name: :user }, type: :hash
        end
      end
    end

    let(:users) { container.relations[:users] }
    let(:tasks) { container.relations[:tasks] }

    let(:joe) {
      Test::User.new(
        name: 'Joe',
        email: 'joe@doe.org',
        tasks: [
          Test::Task.new(title: 'be nice', meta: { user: 'Joe', priority: 1 },
                         tags: []),
          Test::Task.new(title: 'sleep well', meta: { user: 'Joe', priority: 2 },
                         tags: [])
        ],
        address: Test::Address.new(city: 'Boston'),
        book: { title: 'Book Two', user: 'Joe' }
      )
    }

    let(:jane) {
      Test::User.new(
        name: 'Jane',
        email: 'jane@doe.org',
        tasks: [
          Test::Task.new(
            title: 'be cool',
            meta: { user: 'Jane', priority: 2 },
            tags: [Test::Tag.new(name: 'blue')]
          )
        ],
        address: Test::Address.new(city: 'NYC'),
        book: { title: 'Book One', user: 'Jane' }
      )
    }

    it 'works' do
      container

      Test::User.send(:include, Dry::Equalizer(:name, :email, :tasks, :address, :book))
      Test::Task.send(:include, Dry::Equalizer(:title, :meta))
      Test::Address.send(:include, Dry::Equalizer(:city))

      result = users.combine_with(
        tasks.as(:tasks).for_users.combine_with(tasks.tags.as(:tags)),
        users.addresses.as(:addresses),
        users.books.as(:books)
      ) >> users.mappers[:entity]

      expect(result).to match_array([joe, jane])
    end
  end
end
