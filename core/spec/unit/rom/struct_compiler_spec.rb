require 'rom/struct_compiler'

RSpec.describe ROM::StructCompiler, '#call' do
  subject(:struct_compiler) { ROM::StructCompiler.new }

  def attr_ast(name, type, **opts)
    [name, ROM::Types.const_get(type).to_ast, alias: false, wrapped: false]
  end

  let(:input) do
    [:users, [[:attribute, attr_ast(:id, :Integer)], [:attribute, attr_ast(:name, :String)]]]
  end

  context 'ROM::Struct' do
    it 'generates a struct for a given relation name and columns' do
      struct = struct_compiler[*input, ROM::Struct]

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
      expect(struct_compiler[*input, ROM::Struct]).to be(struct_compiler[*input, ROM::Struct])
    end

    context 'with reserved keywords as attribute names' do
      let(:input) do
        [:users, [[:attribute, attr_ast(:id, :Integer)],
                    [:attribute, attr_ast(:name, :String)],
                    [:attribute, attr_ast(:alias, :String)],
                    [:attribute, attr_ast(:until, :Time)]]]
      end

      it 'allows to build a struct class without complaining' do
        struct = struct_compiler[*input, ROM::Struct]

        user = struct.new(id: 1, name: 'Jane', alias: 'JD', until: Time.new(2030))

        expect(user.id).to be(1)
        expect(user.name).to eql('Jane')
        expect(user.alias).to eql('JD')
        expect(user.until).to eql(Time.new(2030))
      end
    end

    it 'raise a friendly error on missing keys' do
      struct = struct_compiler[*input, ROM::Struct]

      expect { struct.new(id: 1) }.to raise_error(Dry::Struct::Error, /:name is missing/)
    end
  end

  context 'with constrained types' do
    let(:input) do
      [:posts, [[:attribute, [:id, ROM::Types::Strict::Integer.to_ast, alias: false, wrapped: false]],
                [:attribute, [:status, ROM::Types::Strict::String.enum(%(Foo Bar)).to_ast, alias: false, wrapped: false]]]]
    end

    let(:struct) do
      struct_compiler[*input, ROM::Struct]
    end

    it 'reduces a constrained type to plain definition' do
      expect(struct.schema.key(:id).type).to_not be_constrained
    end

    it 'reduces an enum type to plain definition' do
      expect(struct.schema.key(:status).type).to_not be_constrained
    end
  end

  context 'custom entity container' do
    before do
      module Test
        module Custom
        end
      end
    end

    let(:struct) { struct_compiler[*input, Test::Custom] }

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
      }.to raise_error(ROM::Struct::MissingAttribute, /attribute not loaded\?/)
    end

    it 'works with implicit coercions' do
      user = struct.new(id: 1, name: 'Jane')

      expect([user].flatten).to eql([user])
    end

    it 'generates a proper error if with overridden getters and a missing method in them' do
      class Test::Custom::User < ROM::Struct
        def name
          first_name
        end
      end

      user = struct.new(id: 1, name: 'Jane')

      expect {
        user.name
      }.to raise_error(ROM::Struct::MissingAttribute, /attribute not loaded\?/)
    end
  end
end
