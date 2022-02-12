# frozen_string_literal: true

require "rom/setup"

RSpec.shared_context "runtime" do
  let(:runtime) { ROM(:memory) }
  let(:registry) { setup.finalize }
  let(:gateway) { registry.gateways[:default] }
  let(:users_relation) { registry.relations[:users] }
  let(:tasks_relation) { registry.relations[:tasks] }
  let(:users_dataset) { gateway.dataset(:users) }
  let(:tasks_dataset) { gateway.dataset(:tasks) }
end
