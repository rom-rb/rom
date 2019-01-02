require 'rom/command'
require 'rom/plugins/command/alias'

RSpec.describe ROM::Plugins::Command::Alias do
  include_context 'container'

  let(:users) { container.commands.users }
  let(:command) { users.create }

  before do
    configuration.relation :users do
      schema(:users) do
        attribute :first_name, Types::String.meta(alias: :name)
      end
    end

    configuration.commands(:users) do
      define :create, type: :create do
        result :one
        use :alias
      end
    end
  end

  it 'accepts input with aliased names' do
    result = command.call(name: 'Joe')

    expect(result[:first_name]).to eq('Joe')
  end

  it 'accepts input with canonical names' do
    result = command.call(first_name: 'Joe')

    expect(result[:first_name]).to eq('Joe')
  end
end
