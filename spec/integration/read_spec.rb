require 'spec_helper'

describe Env, '#read' do
  let(:rom) do
    ROM.setup(sqlite: SEQUEL_TEST_DB_URI) do
      schema do
        base_relation(:users) do
          repository :sqlite
          attribute :id, Integer
        end
      end
    end
  end

  before do
    rom.sqlite.connection.run('CREATE TABLE users (id SERIAL)')
    rom.sqlite.connection[:users].insert(id: 231)
  end

  after do
    rom.sqlite.connection.drop_table? :users
    Object.send(:remove_const, :User)
  end

  it 'exposes a relation reader' do
    rom.relations do
      users do
        def by_id(id)
          where(id: id)
        end

        def sorted
          order(:id)
        end
      end
    end

    rom.mappers do
      users do
        by_id do
          model('User', :id)
        end
      end
    end

    users = rom.read(:users).sorted.by_id(231)
    user = users.first

    expect(user).to be_an_instance_of(User)
    expect(user.id).to eql 231
  end
end
