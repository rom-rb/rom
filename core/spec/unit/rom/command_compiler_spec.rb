require 'spec_helper'

RSpec.describe 'ROM::CommandCompiler' do
  include_context 'gateway only'
  include_context 'users and tasks'

  let(:users) do
    Class.new(ROM::Memory::Relation) do
      def by_id(id)
        restrict(id: id)
      end
    end.new(users_dataset)
  end

  subject(:compiler) do
    ROM::CommandCompiler.new(gateways, relations, registry, notifications)
  end


  let(:gateways) { { default: gateway } }
  let(:relations) { { users: users } }
  let(:registry) {  }
  let(:notifications) { double(trigger: nil) }
  let(:users_ast) do
    [:users,
     [[:attribute,
       [:id, [:nominal, [Integer, {}]], primary_key: true]],
      [:attribute,
       [:name, [:nominal, [String, {}]], {:source=>:users}]]],
     dataset: :users]
  end

  let(:command_class) do
    Class.new(ROM::Commands::Create[:memory])
  end

  describe '#[]' do
    let(:second_compiler) do
      ROM::CommandCompiler.new(gateways, relations, registry, notifications)
    end

    it 'builds commands using ast' do
      command = compiler[:create, :memory, [:relation, users_ast], [], {}, {}]
      expect(command).to be_a(ROM::Memory::Commands::Create)
    end

    it "doesn't use a global cache" do
      args = [:create, :memory, [:relation, users_ast], [], {}, {}]
      command = compiler[*args]
      second_command = second_compiler[*args]

      expect(command).not_to be(second_command)
    end
  end
end
