# frozen_string_literal: true

require "rom/compat"
require "spec_helper"

RSpec.describe "Commands" do
  include_context "container"
  include_context "users and tasks"

  before do
    configuration.relation(:users) do
      def by_id(id)
        restrict(id: id)
      end
    end

    configuration.commands(:users) do
      define(:update)
      define(:create)
    end
  end

  let(:create) { container.commands[:users][:create] }
  let(:update) { container.commands[:users][:update] }

  describe "#method_missing" do
    it "forwards known relation view methods" do
      expect(update.by_id(1).relation).to eql(users_relation.by_id(1))
    end

    it "raises no-method error when a non-view relation method was sent" do
      expect { update.map_with(:foo) }.to raise_error(NoMethodError, /map_with/)
    end

    it "does not forward relation view methods to non-restrictable commands" do
      expect { create.by_id(1) }.to raise_error(NoMethodError, /by_id/)
    end
  end
end
