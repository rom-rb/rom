require 'rom/schema'

RSpec.describe ROM::Schema, '#project' do
  subject(:schema) do
    ROM::Schema.define(
      :users, attributes: {
        id: ROM::Types::Int.meta(name: :id),
        name: ROM::Types::String.meta(name: :name),
        age: ROM::Types::Int.meta(name: :age)
      }
    )
  end

  it 'projects provided attribute names' do
    expect(schema.project(:name, :age).map(&:name)).to eql(%i[name age])
  end
end
