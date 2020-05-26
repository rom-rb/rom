# frozen_string_literal: true

require 'rom/schema'

RSpec.describe ROM::Schema, '#wrap' do
  subject(:schema) do
    define_schema(:users, id: :Integer, name: :String)
  end

  let(:wrapped) do
    schema.wrap(:users)
  end

  it 'returns projected schema with renamed attributes using provided prefix' do
    expect(wrapped.map(&:alias)).to eql(%i[users_id users_name])
    expect(wrapped.map(&:name)).to eql(%i[id name])
    expect(wrapped.all?(&:wrapped?)).to be(true)
    expect(wrapped.wrap(:foo)).to eql(wrapped)
  end
end
