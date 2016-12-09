require 'spec_helper'

require 'rom/memory'

RSpec.describe ROM::Memory::Commands::Update do
  include_context 'container'
  include_context 'users and tasks'

  before do
    configuration.relation(:users) do
      def by_id(id)
        restrict(id: id)
      end
    end
    configuration.commands(:users) do
      define(:update)
    end
  end

  subject(:command) { container.command(:users).update }

  it_behaves_like 'a command'
end
