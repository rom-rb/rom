# frozen_string_literal: true

require "rom/repository"

RSpec.describe ROM::Repository::Root do
  subject(:repo) do
    klass.new(rom)
  end

  let(:klass) do
    Class.new(ROM::Repository[:users])
  end

  include_context 'repository / database'
  include_context 'relations'

  describe '.[]' do
    it 'creates a pre-configured root repo class' do
      klass = ROM::Repository[:users]

      expect(klass.root).to be(:users)

      child = klass[:users]

      expect(child.root).to be(:users)
      expect(child < klass).to be(true)
    end
  end

  describe 'inheritance' do
    it 'inherits root and relations' do
      klass = Class.new(repo.class)

      expect(klass.root).to be(:users)
    end

    it 'creates base root class' do
      klass = Class.new(ROM::Repository)[:users]

      expect(klass.root).to be(:users)
    end
  end

  describe 'overriding reader' do
    it 'works with super' do
      klass.class_eval do
        def users
          super.limit(10)
        end
      end

      expect(repo.users.dataset.opts[:limit]).to be(10)
    end
  end

  describe '#root' do
    it 'returns configured root relation' do
      expect(repo.root.dataset).to be(rom.relations[:users].dataset)
    end
  end
end
