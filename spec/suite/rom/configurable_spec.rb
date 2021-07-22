# frozen_string_literal: true

require "rom/support/configurable"

RSpec.describe ROM::Configurable, :isolation do
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

    describe "#inherit" do
      it "updates child config using parent config" do
        parent do
          setting(:gateway, default: "main")
          setting(:adapter, default: :memory)
          setting(:abstract, default: false)
        end

        child do
          setting(:gateway, inherit: true)
          setting(:adapter, inherit: true)
          setting(:abstract, inherit: true)
        end

        merged = child.config.inherit(parent.config)

        expect(merged.gateway).to eql("main")
        expect(merged.adapter).to be(:memory)
        expect(merged.abstract).to be(false)
      end

      it "joins array values" do
        parent do
          setting(:plugins, inherit: true)
        end

        child do
          setting(:plugins, inherit: true)
        end

        parent.config.plugins = [:one, :two]
        child.config.plugins = [:two, :three]

        merged = child.config.inherit(parent.config)

        expect(parent.config.plugins).to eql([:one, :two])
        expect(child.config.plugins).to eql([:two, :three])

        expect(merged.plugins).to eql([:one, :two, :three])
      end

      it "merges hash values" do
        parent do
          setting(:opts, inherit: true)
        end

        child do
          setting(:opts, inherit: true)
        end

        parent.config.opts = {one: 1, two: 2}
        child.config.opts = {three: 3}

        merged = child.config.inherit(parent.config)

        expect(parent.config.opts).to eql(one: 1, two: 2)
        expect(child.config.opts).to eql(three: 3)

        expect(merged.opts).to eql(one: 1, two: 2, three: 3)
      end
    end

    describe "#join" do
      before do
        parent do
          setting(:namespace, join: true)
        end

        child do
          setting(:namespace, join: true)
        end
      end

      it "joins strings using default separator" do
        parent.config.namespace = "parent"
        child.config.namespace = "child"

        left = child.config.join(parent.config)
        right = parent.config.join(child.config, :right)

        expect(left.namespace).to eql("parent.child")
        expect(right.namespace).to eql("parent.child")
      end

      it "works with hashes" do
        child.config.namespace = "child"

        hash = {namespace: "other"}

        left = child.config.join(hash)
        right = child.config.join(hash, :right)

        expect(left.namespace).to eql("other.child")
        expect(right.namespace).to eql("child.other")
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
