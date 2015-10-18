require 'spec_helper'

require 'rom/memory'

describe ROM::Memory::Commands::Delete do
  include_context 'users and tasks'

  subject(:command) { rom.command(:users)[:delete] }

  let(:users) { rom.relations[:users] }

  before do
    setup.relation(:users) do
      def by_id(id)
        restrict(id: id)
      end
    end

    setup.commands(:users) { define(:delete) }
  end

  it_behaves_like 'a command'
end
