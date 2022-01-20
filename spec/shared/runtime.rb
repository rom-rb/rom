# frozen_string_literal: true

require "rom/runtime"

RSpec.shared_context "runtime" do
  let(:runtime) { ROM::Runtime.new(:memory) }
  let(:resolver) { runtime.finalize }
  let(:gateway) { resolver.gateways[:default] }
  let(:users_relation) { resolver.relations[:users] }
  let(:tasks_relation) { resolver.relations[:tasks] }
  let(:users_dataset) { gateway.dataset(:users) }
  let(:tasks_dataset) { gateway.dataset(:tasks) }
end
