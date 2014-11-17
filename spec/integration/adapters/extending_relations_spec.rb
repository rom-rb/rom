require "spec_helper"

describe "Adapter" do
  include_context "users and tasks" do
    before(:all) do
      Class.new(ROM::SQL::Adapter) do
        def self.schemes
          [:sqlite]
        end

        def extend_relation_class(klass)
          klass.class_eval do
            def self.freaking_awesome?
              true
            end
          end
        end

        def extend_relation_instance(relation)
          relation.instance_eval do
            def freaking_cool?
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

  it "can extend relation instance" do
    expect(rom.relations.users).to be_freaking_cool
  end
end
