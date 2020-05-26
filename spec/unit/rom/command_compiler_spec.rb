# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ROM::CommandCompiler' do
  include_context 'gateway only'
  include_context 'users and tasks'

  let(:users) do
    Class.new(ROM::Memory::Relation) {
      def by_id(id)
        restrict(id: id)
      end
    }.new(users_dataset)
  end

  subject(:compiler) do
    ROM::CommandCompiler.new(gateways, relations, registry, notifications)
  end

  let(:gateways) { { default: gateway } }
  let(:relations) { { users: users } }
  let(:registry) {}
  let(:notifications) { double(trigger: nil) }
  let(:users_ast) do
    [:users,
     [[:attribute,
       [:id, [:nominal, [Integer, {}]], primary_key: true]],
      [:attribute,
       [:name, [:nominal, [String, {}]], { source: :users }]]],
     dataset: :users]
  end

  let(:command_class) do
    Class.new(ROM::Commands::Create[:memory])
  end

  describe '#[]' do
    let(:second_compiler) do
      ROM::CommandCompiler.new(gateways, relations, registry, notifications)
    end

    let(:options) { {} }

    let(:args) { [:create, :memory, [:relation, users_ast], [], {}, options] }

    let(:command) { compiler[*args] }

    it 'builds commands using ast' do
      expect(command).to be_a(ROM::Memory::Commands::Create)
    end

    context 'options' do
      let(:input) { -> t { t } }

      let(:options) { { input: input } }

      it 'builds commands using custom options' do
        expect(command.input).to be(input)
      end
    end

    it "doesn't use a global cache" do
      expect(command).not_to be(second_compiler[*args])
    end

    describe 'setting input from relation' do
      let(:name) do
        ROM::Attribute.new(ROM::Types::String.constructor { |v| "relation[#{v}]" }, name: :name)
      end

      let(:users) do
        users = super()
        schema = users.schema.append(name)
        users.with(schema: schema)
      end

      it 'uses input schema from relation and does it once' do
        expect(command.input[{ id: 1, name: 'John' }][:name]).to eql("relation[John]")
      end
    end
  end
end
