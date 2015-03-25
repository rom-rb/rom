require 'spec_helper'

describe ROM::Env do
  include_context 'users and tasks'

  before do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name).project(:name)
      end
    end

    setup.relation(:tasks)

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
    it 'yields selected relation to the block and returns a loaded relation' do
      result = rom.relation(:users) { |r| r.by_name('Jane') }.as(:name_list)

      expect(result.call).to match_array([{ name: 'Jane' }])
    end

    it 'returns lazy-mapped relation' do
      by_name = rom.relation(:users).as(:name_list).by_name

      expect(by_name['Jane']).to match_array([{ name: 'Jane' }])
    end

    it 'returns lazy relation without mappers when mappers are not defined' do
      expect(rom.relation(:tasks)).to be_instance_of(ROM::Relation::Lazy)
      expect(rom.relation(:tasks).relation).to be(rom.relations.tasks)
    end
  end

  describe '#read' do
    it 'returns loaded relation and display a deprecation warning' do
      expect {
        result = rom.read(:users) { |r| r.by_name('Jane') }.as(:name_list)
        expect(result.call).to match_array([{ name: 'Jane' }])
      }.to output(/^ROM::Env#read is deprecated/).to_stderr
    end
  end

  describe '#mappers' do
    it 'returns mappers for all relations' do
      expect(rom.mappers.users[:name_list]).to_not be(nil)
    end
  end
end
