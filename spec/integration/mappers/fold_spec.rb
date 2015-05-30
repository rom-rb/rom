require 'spec_helper'

describe 'Mapper definition DSL' do
  include_context 'users and tasks'

  let(:header) { mapper.header }

  describe 'folded relation mapper' do
    before do
      setup.relation(:tasks) do
        def with_users
          join(users)
        end
      end

      setup.relation(:users) do
        def with_tasks
          join(tasks)
        end
      end
    end

    let(:rom) { setup.finalize }
    let(:actual) do
      rom.relation(:users).with_tasks.map_with(:users).to_a
    end

    it 'groups all attributes and folds the first key' do
      setup.mappers do
        define(:users) do
          fold tasks: [:title, :priority]
        end
      end

      expect(actual).to eql [
        { name: 'Joe', email: 'joe@doe.org', tasks: ['be nice', 'sleep well'] },
        { name: 'Jane', email: 'jane@doe.org', tasks: ['be cool'] }
      ]
    end

    it 'is sensitive to the order of keys' do
      setup.mappers do
        define(:users) do
          fold priorities: [:priority, :title]
        end
      end

      expect(actual).to eql [
        { name: 'Joe', email: 'joe@doe.org', priorities: [1, 2] },
        { name: 'Jane', email: 'jane@doe.org', priorities: [2] }
      ]
    end

    it 'accepts the block syntax' do
      setup.mappers do
        define(:users) do
          fold :priorities do
            attribute :priority
            attribute :title
          end
        end
      end

      expect(actual).to eql [
        { name: 'Joe', email: 'joe@doe.org', priorities: [1, 2] },
        { name: 'Jane', email: 'jane@doe.org', priorities: [2] }
      ]
    end
  end
end
