require 'spec_helper'

describe Env, '#mappers' do
  include_context 'users and tasks'

  let(:header) { mapper.header }

  before do
    rom.relations do
      register(:users) do

        def email_index
          select(:email)
        end

      end
    end
  end

  after do
    Object.send(:remove_const, :User) if Object.const_defined?(:User)
  end

  describe 'defining a default PORO mapper' do
    subject(:mapper) { rom.read(:users).mapper }

    before do
      rom.mappers do
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

  describe 'defining a mapper with custom attributes' do
    subject(:mapper) { rom.read(:users).mapper }

    before do
      rom.mappers do
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

  describe 'defining a mapper for a virtual relation' do
    subject(:mapper) { rom.read(:users).email_index.mapper }

    before do
      rom.mappers do
        define(:users) do
          model name: 'User'
        end

        define(:email_index, parent: users) do
          exclude :name
        end
      end
    end

    it 'inherits the model from the parent by default' do
      expect(mapper.model).to be(User)
    end

    it 'only maps provided attributes' do
      expect(header.keys).to eql([:email])
    end
  end

end
