# frozen_string_literal: true

require "rom/runtime"

RSpec.shared_context "runtime" do
  let(:runtime) { ROM::Runtime.new(:memory) }
  let(:registry) { runtime.finalize }
  let(:gateway) { registry.gateways[:default] }
  let(:users_relation) { registry.relations[:users] }
  let(:tasks_relation) { registry.relations[:tasks] }
  let(:users_dataset) { gateway.dataset(:users) }
  let(:tasks_dataset) { gateway.dataset(:tasks) }
end
