# frozen_string_literal: true

require "rom/support/configurable"

RSpec.describe ROM::Configurable do
  subject(:component) do
    Test::Component.new
  end

  before do
    module Test
      class Parent
        extend ROM::Configurable
      end

      class Child
        extend ROM::Configurable
      end
    end
  end

  def parent(&block)
    return Test::Parent unless block
    Test::Parent.class_eval(&block)
  end

  def child(&block)
    return Test::Child unless block
    Test::Child.class_eval(&block)
  end

  describe ".import_settings" do
    it "merges settings from another configurable" do
      parent do
        setting :component do
          setting :adapter
          setting :gateway, default: :default
        end
      end

      child.setting(:dataset, import: parent.settings[:component])

      expect(child.config.dataset.adapter).to be(nil)
      expect(child.config.dataset.gateway).to be(:default)

      parent.config.component.adapter = :memory
      child.config.dataset.gateway = :main

      expect(parent.config.component.adapter).to be(:memory)
      expect(parent.config.component.gateway).to be(:default)

      expect(child.config.dataset.adapter).to be(nil)
      expect(child.config.dataset.gateway).to be(:main)

    end
  end

  describe "Config" do
    describe "#key?" do
      it "returns true when key is defined as a setting" do
        child do
          setting(:gateway)
        end

        expect(child.config.key?(:gateway)).to be(true)
      end

      it "returns false when key is not defined as a setting" do
        expect(child.config.key?(:not_here)).to be(false)
      end
    end

    describe "#inherit!" do
      it "updates child config using parent config" do
        parent do
          setting(:component) do
            setting(:adapter)
            setting(:gateway, default: "main")
          end

          setting(:dataset) do
            setting(:adapter, default: :memory)
          end
        end

        child do
          setting(:inherit) do
            setting(:paths, default: %i[component dataset])
            setting(:compose, default: [])
          end

          setting(:adapter)
          setting(:gateway)
        end

        child.config.inherit!(parent.config)

        expect(child.config.adapter).to be(:memory)
        expect(child.config.gateway).to eql("main")
      end
    end

    describe "#inherit" do
      it "inherits parent config into a duped child config" do
        parent do
          setting(:component) do
            setting(:custom, default: "not-inheritable")
            setting(:gateway, default: "main")
          end

          setting(:dataset) do
            setting(:adapter, default: :memory)
          end
        end

        child do
          setting(:inherit) do
            setting(:paths, default: %i[component dataset])
            setting(:compose, default: [])
          end

          setting(:adapter)
          setting(:gateway)
        end

        merged = child.config.inherit(parent.config)

        expect(merged.adapter).to be(:memory)
        expect(merged.gateway).to eql("main")

        expect(child.config.adapter).to be(nil)
        expect(child.config.gateway).to be(nil)
      end

      it "inherits composable values" do
        module Test
          Namespace = ROM::Types::String.constructor do |input|
            Array(input).join(".") if input
          end
        end

        parent do
          setting(:component) do
            setting(:namespace, default: "root")
          end

          setting(:dataset) do
            setting(:id, default: "parent")
            setting(:namespace, default: "datasets")
          end
        end

        child do
          setting(:inherit) do
            setting(:paths, default: %i[component dataset])
            setting(:compose, default: %i[namespace])
          end

          setting(:id, default: "child")
          setting(:namespace, constructor: Test::Namespace)
        end

        child.config.inherit!(parent.config)

        expect(child.config.id).to eql("child")
        expect(child.config.namespace).to eql("root.datasets")
      end

      it "inherits composable values with an existing value" do
        module Test
          Namespace = ROM::Types::String.constructor do |input|
            Array(input).join(".") if input
          end
        end

        parent do
          setting(:component) do
            setting(:namespace, default: "root")
          end

          setting(:dataset) do
            setting(:namespace, default: "datasets")
          end
        end

        child do
          setting(:inherit) do
            setting(:paths, default: %i[component dataset])
            setting(:compose, default: %i[namespace])
          end

          setting(:namespace, constructor: Test::Namespace, default: "users")
        end

        child.config.inherit!(parent.config)

        expect(child.config.namespace).to eql("root.datasets.users")
      end
    end

    describe "#to_hash" do
      let(:hash) { Hash(child.config) }

      before do
        child do
          setting(:adapter, default: :memory)
          setting(:gateway, default: "main")
        end
      end

      it "returns a hash copy" do
        expect(hash).to eql(adapter: :memory, gateway: "main")
      end

      it "returns a copy of the config's hash" do
        hash.update(foo: "bar")

        expect(hash).to eql(adapter: :memory, gateway: "main", foo: "bar")
        expect(Hash(child.config)).to eql(adapter: :memory, gateway: "main")
      end
    end
  end
end
