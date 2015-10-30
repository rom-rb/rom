require 'spec_helper'

describe ROM::Container do
  include_context 'users and tasks'

  before do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name).project(:name)
      end
    end

    setup.relation(:tasks)

    setup.commands(:users) do
      define(:create)
    end

    setup.commands(:tasks) do
      define(:create)
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

  describe '#command' do
    it 'returns registered command registry' do
      expect(rom.command(:users)).to be_instance_of(ROM::CommandRegistry)
    end

    it 'returns registered command' do
      expect(rom.command(:users).create).to be_kind_of(ROM::Commands::Create)
    end

    it 'accepts an array with graph options and input' do
      expect(rom.command([:users, [:create]])).to be_kind_of(ROM::Commands::Lazy)
    end

    it 'raises ArgumentError when unsupported arg was passed' do
      expect { rom.command(oops: 'sorry') }.to raise_error(ArgumentError)
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

    it 'returns relation without mappers when mappers are not defined' do
      expect(rom.relation(:tasks)).to be_kind_of(ROM::Relation)
      expect(rom.relation(:tasks).mappers.elements).to be_empty
    end
  end

  describe '#mappers' do
    it 'returns mappers for all relations' do
      expect(rom.mappers.users[:name_list]).to_not be(nil)
    end
  end
end
