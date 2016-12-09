require 'spec_helper'

RSpec.describe ROM::MapperRegistry do
  subject(:registry) { ROM::MapperRegistry.new }

  let(:user_mapper) { double('user_mapper') }
  let(:index_mapper) { double('index_mapper') }

  before do
    registry[:users] = user_mapper
    registry[:index] = index_mapper
  end

  describe '#by_path' do
    it 'returns first matching mapper' do
      mapper = registry.by_path('users')

      expect(mapper).to be(user_mapper)

      mapper = registry.by_path('users.index')

      expect(mapper).to be(index_mapper)
    end
  end
end
