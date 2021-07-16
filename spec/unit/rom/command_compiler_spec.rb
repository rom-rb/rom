# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ROM::CommandCompiler" do
  subject(:compiler) do
    ROM::CommandCompiler.new(registry: registry.commands.scoped(:users))
  end

  include_context "gateway only"
  include_context "users and tasks"

  let(:users) do
    klass = Class.new(ROM::Memory::Relation) {
      def by_id(id)
        restrict(id: id)
      end
    }
    klass.dataset { users_dataset }
    klass
  end

  let(:users_ast) do
    [:users,
     [[:attribute,
       [:id, [:nominal, [Integer, {}]], primary_key: true]],
      [:attribute,
       [:name, [:nominal, [String, {}]], {source: :users}]]],
     dataset: :users]
  end

  let(:command_class) do
    Class.new(ROM::Commands::Create[:memory])
  end

  def registry
    ROM::Registry.new.tap do |reg|
      reg.components.add(
        :relations, constant: users, config: users.config.component.merge(id: :users)
      )
    end
  end

  describe "#[]" do
    let(:second_compiler) do
      ROM::CommandCompiler.new(registry: registry.commands.scoped(:users))
    end

    let(:options) { {} }

    let(:args) { [:create, :memory, [:relation, users_ast], [], {}, options] }

    let(:command) { compiler[*args] }

    it "builds commands using ast" do
      expect(command).to be_a(ROM::Memory::Commands::Create)
    end

    context "options" do
      let(:input) { -> t { t } }

      let(:options) { {input: input} }

      it "builds commands using custom options" do
        expect(command.input).to be(input)
      end
    end

    it "doesn't use a global cache" do
      expect(command).not_to be(second_compiler[*args])
    end

    describe "setting input from relation" do
      let(:users) do
        super().tap do |klass|
          klass.schema do
            attribute :name, ROM::Types::String.constructor { |v| "relation[#{v}]" }
          end
        end
      end

      it "uses input schema from relation and does it once" do
        expect(command.input[{id: 1, name: "John"}][:name]).to eql("relation[John]")
      end
    end
  end
end
