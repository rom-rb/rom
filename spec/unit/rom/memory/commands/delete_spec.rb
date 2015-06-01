require 'spec_helper'

describe ROM::Memory::Commands::Create do
  include_context 'users and tasks'

  subject(:command) { ROM::Memory::Commands::Create.build(users) }

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
