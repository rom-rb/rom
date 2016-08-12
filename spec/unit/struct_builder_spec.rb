RSpec.describe 'struct builder', '#call' do
  subject(:builder) { ROM::Repository::StructBuilder.new }

  let(:input) { [:users, [:header, [[:attribute, :id], [:attribute, :name]]]] }

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
    let(:input) { [:users, [:header, [[:attribute, :id], [:attribute, :name],
                                      [:attribute, :alias], [:attribute, :until]]]] }

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
      ROM::Struct::InvalidAttributes,
      /missing: :name/
    )
  end

  it 'raise a friendly error on superflous keys' do
    struct = builder.class.cache[input.hash]

    expect {
      struct.new(id: 1, name: 'Jane', foo: 'bar', baz: 'quux')
    }.to raise_error(
      ROM::Struct::InvalidAttributes,
      /unknown: :foo, :baz/
    )
  end
end
