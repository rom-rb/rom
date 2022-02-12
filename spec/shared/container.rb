# frozen_string_literal: true

require "rom/setup"

RSpec.shared_context "container" do
  let(:setup) { ROM::Setup.new(:memory) }
  let(:registry) { setup.finalize }
  let(:configuration) { setup }
  let(:container) { registry }
  let(:gateway) { registry.gateways[:default] }
  let(:users_relation) { container.relations[:users] }
  let(:tasks_relation) { container.relations[:tasks] }
  let(:users_dataset) { gateway.dataset(:users) }
  let(:tasks_dataset) { gateway.dataset(:tasks) }
end
