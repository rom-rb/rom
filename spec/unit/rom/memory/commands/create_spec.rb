require 'spec_helper'

require 'rom/memory'

describe ROM::Memory::Commands::Create do
  include_context 'users and tasks'

  subject(:command) { container.command(:users)[:create] }

  let(:users) { container.relations[:users] }

  before do
    configuration.relation(:users) do
      def by_id(id)
        restrict(id: id)
      end
    end

    configuration.commands(:users) do
      define(:create)
    end
  end

  it_behaves_like 'a command'
end
