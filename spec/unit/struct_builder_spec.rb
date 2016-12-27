RSpec.describe 'struct builder', '#call' do
  subject(:builder) { ROM::Repository::StructBuilder.new }

  let(:input) do
    [:users, [:header, [
                [:attribute, double(name: :id, type: ROM::Types::Int, foreign_key?: false)],
                [:attribute, double(name: :name, type: ROM::Types::String, foreign_key?: false)]]]]
  end

  before { builder[*input] }

  it 'generates a struct for a given relation name and columns' do
    struct = builder.class.cache[input.hash]

    user = struct.new(id: 1, name: 'Jane')

    expect(user.id).to be(1)
    expect(user.name).to eql('Jane')

    expect(user[:id]).to be(1)
    expect(user[:name]).to eql('Jane')

    expect(Hash[user]).to eql(id: 1, name: 'Jane')

    expect(user.inspect).to eql('#<ROM::Struct[User] id=1 name="Jane">')
    expect(user.to_s).to match(/\A#<ROM::Struct\[User\]:0x[0-9a-f]+>\z/)
  end

  it 'stores struct in the cache' do
    expect(builder.class.cache[input.hash]).to be(builder[*input])
  end

  context 'with reserved keywords as attribute names' do
    let(:input) do
      [:users, [:header, [
                  [:attribute, double(name: :id, type: ROM::Types::Int, foreign_key?: false)],
                  [:attribute, double(name: :name, type: ROM::Types::String, foreign_key?: false)],
                  [:attribute, double(name: :alias, type: ROM::Types::String, foreign_key?: false)],
                  [:attribute, double(name: :until, type: ROM::Types::Time, foreign_key?: false)]]]]
    end

    it 'allows to build a struct class without complaining' do
      struct = builder.class.cache[input.hash]

      user = struct.new(id: 1, name: 'Jane', alias: 'JD', until: Time.new(2030))

      expect(user.id).to be(1)
      expect(user.name).to eql('Jane')
      expect(user.alias).to eql('JD')
      expect(user.until).to eql(Time.new(2030))
    end
  end

  it 'raise a friendly error on missing keys' do
    struct = builder.class.cache[input.hash]

    expect { struct.new(id: 1) }.to raise_error(
      Dry::Struct::Error, /:name is missing/
    )
  end
end
