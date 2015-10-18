require 'spec_helper'

require 'rom/memory'

describe ROM::Memory::Commands::Create do
  include_context 'users and tasks'

  subject(:command) { rom.command(:users)[:create] }

  let(:users) { rom.relations[:users] }

  before do
    setup.relation(:users) do
      def by_id(id)
        restrict(id: id)
      end
    end

    setup.commands(:users) do
      define(:create)
    end
  end

  it_behaves_like 'a command'
end
