# frozen_string_literal: true

require 'rom/schema'

RSpec.describe ROM::Schema, '#prefix' do
  subject(:schema) do
    define_schema(:users, id: :Integer, name: :String)
  end

  let(:prefixed) do
    schema.prefix(:user)
  end

  it 'returns projected schema with renamed attributes using provided prefix' do
    expect(prefixed.map(&:alias)).to eql(%i[user_id user_name])
    expect(prefixed.map(&:name)).to eql(%i[id name])
  end
end
