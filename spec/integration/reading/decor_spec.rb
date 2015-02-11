require 'spec_helper'
require 'ostruct'

describe 'Reading / Decoration' do
  include_context 'users and tasks'

  it 'allows setting a decorator' do
    UserPresenter = Class.new(OpenStruct) {
      def name
        super.upcase
      end
    }

    UserDecor = proc { |user| UserPresenter.new(user) }

    class Users < ROM::Relation[:memory]
    end

    class UserMapper < ROM::Mapper
      relation :users
      attribute :name
    end

    class UserReader < ROM::Reader
      relation :users
      decors user_decor: UserDecor
    end

    users = rom.read(:users).decorate(:user_decor).map(&:name)

    expect(users).to match_array(%w(JANE JOE))
  end
end
