require 'spec_helper'

require 'rom/memory'

describe ROM::Memory::Commands::Update do
  include_context 'users and tasks'

  subject(:command) { rom.command(:users)[:update] }

  let(:users) { rom.relations[:users] }

  before do
    setup.relation(:users) do
      def by_id(id)
        restrict(id: id)
      end
    end

    setup.commands(:users) { define(:update) }
  end

  it_behaves_like 'a command'
end
