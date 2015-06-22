require 'spec_helper'

require 'rom/memory'

describe ROM::Memory::Commands::Delete do
  include_context 'users and tasks'

  subject(:command) { ROM::Memory::Commands::Delete.build(users) }

  let(:users) { rom.relations[:users] }

  before do
    setup.relation(:users) do
      def by_id(id)
        restrict(id: id)
      end
    end
  end

  it_behaves_like 'a command'
end
