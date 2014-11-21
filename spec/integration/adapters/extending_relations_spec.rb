require "spec_helper"

describe "Adapter" do
  include_context "users and tasks" do
    before(:all) do
      Class.new(ROM::Adapter::Memory) do
        def self.schemes
          [:memory]
        end

        def extend_relation_class(klass)
          klass.class_eval do
            def self.freaking_awesome?
              true
            end
          end
        end

        ROM::Adapter.register(self)
      end
    end
  end

  before do
    setup.relation(:users)
  end

  it "can extend relation class" do
    expect(rom.relations.users.class).to be_freaking_awesome
  end
end
