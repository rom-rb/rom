RSpec.describe 'struct builder', '#call' do
  subject(:builder) { ROM::StructBuilder.new }

  def attr_double(name, type, **opts)
    double(
      name: name,
      aliased?: false,
      wrapped?: false,
      foreign_key?: false,
      to_read_type: ROM::Types.const_get(type),
      **opts
    )
  end

  let(:input) do
    [:users, [[:attribute, attr_double(:id, :Int)], [:attribute, attr_double(:name, :String)]]]
  end

  context 'ROM::Struct' do
    before { builder[*input] }

    it 'generates a struct for a given relation name and columns' do
      struct = builder.class.cache[input.hash]

      user = struct.new(id: 1, name: 'Jane')

      expect(user.id).to be(1)
      expect(user.name).to eql('Jane')

      expect(user[:id]).to be(1)
      expect(user[:name]).to eql('Jane')

      expect(Hash[user]).to eql(id: 1, name: 'Jane')

      expect(user.inspect).to eql('#<ROM::Struct::User id=1 name="Jane">')
      expect(user.to_s).to match(/\A#<ROM::Struct::User:0x[0-9a-f]+>\z/)
    end

    it 'stores struct in the cache' do
      expect(builder.class.cache[input.hash]).to be(builder[*input])
    end

    context 'with reserved keywords as attribute names' do
      let(:input) do
        [:users, [[:attribute, attr_double(:id, :Int)],
                    [:attribute, attr_double(:name, :String)],
                    [:attribute, attr_double(:alias, :String)],
                    [:attribute, attr_double(:until, :Time)]]]
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

  context 'custom entity container' do
    before do
      module Test
        module Custom
        end
      end
    end

    let(:struct) { builder[*input] }
    subject(:builder) { ROM::StructBuilder.new(Test::Custom) }

    it 'generates a struct class inside a given module' do
      expect(struct.name).to eql('Test::Custom::User')
      user = struct.new(id: 1, name: 'Jane')

      expect(user.inspect).to eql(%q{#<Test::Custom::User id=1 name="Jane">})
    end

    it 'uses the existing class as a parent' do
      class Test::Custom::User < ROM::Struct
        def upcased_name
          name.upcase
        end
      end

      user = struct.new(id: 1, name: 'Jane')

      expect(user.upcased_name).to eql('JANE')
    end

    it 'raises a nice error on missing attributes' do
      class Test::Custom::User < ROM::Struct
        def upcased_middle_name
          middle_name.upcase
        end
      end

      user = struct.new(id: 1, name: 'Jane')

      expect {
        user.upcased_middle_name
      }.to raise_error(
             ROM::Struct::MissingAttribute,
             /not loaded attribute\?/
           )
    end

    it 'works with implicit coercions' do
      user = struct.new(id: 1, name: 'Jane')

      expect([user].flatten).to eql([user])
    end
  end
end
