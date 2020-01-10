# frozen_string_literal: true

RSpec.shared_context 'gateway only' do
  let(:gateway) { ROM::Memory::Gateway.new }

  let(:users_dataset) { gateway.dataset(:users) }
  let(:tasks_dataset) { gateway.dataset(:tasks) }
end
