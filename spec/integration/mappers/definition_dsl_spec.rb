require 'spec_helper'

describe 'Mapper definition DSL' do
  include_context 'users and tasks'

  let(:header) { mapper.header }

  before do
    setup.relation(:users) do
      def email_index
        select(:email)
      end
    end
  end

  describe 'default PORO mapper' do
    subject(:mapper) { rom.read(:users).mapper }

    before do
      setup.mappers do
        define(:users) do
          model name: 'User'
        end
      end
    end

    it 'defines a constant for the model class' do
      expect(mapper.model).to be(User)
    end

    it 'uses all attributes from the relation header by default' do
      expect(header.keys).to eql(rom.relations.users.header)
    end
  end

  describe 'excluding attributes' do
    subject(:mapper) { rom.read(:users).mapper }

    before do
      setup.mappers do
        define(:users) do
          model name: 'User'

          exclude :name
        end
      end
    end

    it 'only maps provided attributes' do
      expect(header.keys).to eql([:email])
    end
  end

  describe 'virtual relation mapper' do
    subject(:mapper) { rom.read(:users).email_index.mapper }

    before do
      setup.mappers do
        define(:users) do
          model name: 'User'
        end
      end

      setup.mappers do
        define(:email_index, parent: :users) do
          model name: 'UserWithoutName'
          exclude :name
        end
      end
    end

    it 'inherits the attributes from the parent by default' do
      expect(header.keys).to eql(rom.mappers[:users].header - [:name])
    end

    it 'builds a new model' do
      expect(mapper.model).to be(UserWithoutName)
    end
  end

end
