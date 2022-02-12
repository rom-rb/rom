# frozen_string_literal: true

require "rom/runtime"

RSpec.shared_context "container" do
  let(:runtime) { ROM::Runtime.new(:memory) }
  let(:registry) { runtime.finalize }
  let(:configuration) { runtime }
  let(:container) { registry }
  let(:gateway) { registry.gateways[:default] }
  let(:users_relation) { container.relations[:users] }
  let(:tasks_relation) { container.relations[:tasks] }
  let(:users_dataset) { gateway.dataset(:users) }
  let(:tasks_dataset) { gateway.dataset(:tasks) }
end
