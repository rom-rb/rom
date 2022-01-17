# frozen_string_literal: true

require "rom/runtime"

RSpec.shared_context "container" do
  let(:runtime) { ROM::Runtime.new(:memory) }
  let(:resolver) { runtime.finalize }
  let(:configuration) { runtime }
  let(:container) { resolver }
  let(:gateway) { resolver.gateways[:default] }
  let(:users_relation) { container.relations[:users] }
  let(:tasks_relation) { container.relations[:tasks] }
  let(:users_dataset) { gateway.dataset(:users) }
  let(:tasks_dataset) { gateway.dataset(:tasks) }
end
