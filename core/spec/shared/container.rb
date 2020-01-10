# frozen_string_literal: true

RSpec.shared_context 'container' do
  let(:container) { ROM.container(configuration) }
  let(:configuration) { ROM::Configuration.new(:memory) }
  let(:gateway) { configuration.gateways[:default] }
  let(:users_relation) { container.relations[:users] }
  let(:tasks_relation) { container.relations[:tasks] }
  let(:users_dataset) { gateway.dataset(:users) }
  let(:tasks_dataset) { gateway.dataset(:tasks) }
end
