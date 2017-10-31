require 'rom/schema'

RSpec.describe ROM::Schema, '#valid?' do
  subject(:schema) do
    define_schema(
      :users,
      user_id: :Int, user_name: :String, 'user email' => :String
    )
  end

  it 'returns true when valid' do
    expect(schema.valid?(schema[:user_name])).to be_truthy
  end

  it 'returns false when not valid' do
    expect(schema.valid?(schema['user email'])).to be_falsey
  end
end
