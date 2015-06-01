require 'spec_helper'

describe ROM::Memory::Commands::Update do
  include_context 'users and tasks'

  subject(:command) { ROM::Memory::Commands::Update.build(users) }

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
