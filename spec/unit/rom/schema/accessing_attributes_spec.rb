require 'rom/schema'

RSpec.describe ROM::Schema, '#[]' do
  subject(:schema) do
    define_schema(:users, id: :Int, name: :String, email: :String)
  end

  it 'returns an attribute identified by its canonical name' do
    expect(schema[:email]).to eql(define_type(:email, :String))
  end

  it 'returns an aliased attribute identified by its canonical name' do
    expect(schema.rename(id: :user_id)[:id]).to eql(define_type(:id, :Int, alias: :user_id))
  end
end
