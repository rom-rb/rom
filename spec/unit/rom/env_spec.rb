require 'spec_helper'

describe ROM::Env do
  include_context 'users and tasks'

  before do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name).project(:name)
      end
    end

    setup.mappers do
      define(:users) do
        attribute :name
        attribute :email
      end

      define(:name_list, parent: :users) do
        attribute :name
        exclude :email
      end
    end
  end

  describe '#relation' do
    it 'yields selected relation to the block and returns a reader' do
      result = rom.relation(:users) { |r| r.by_name('Jane') }.map_with(:name_list)
      expect(result).to match_array([{ name: 'Jane' }])
    end
  end

  describe '#mappers' do
    it 'returns mappers for all relations' do
      expect(rom.mappers.users).to eql(rom.readers.users.mappers)
    end
  end
end
