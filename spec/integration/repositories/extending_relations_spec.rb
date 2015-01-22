require "spec_helper"

describe "Repository" do
  include_context "users and tasks" do
    before(:context) do
      extending_repo = Class.new(ROM::Memory::Repository) do
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

        def extend_relation_instance(relation)
          relation.instance_eval do
            def freaking_cool?
              true
            end
          end
        end
      end

      register_repo extending_repo
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
