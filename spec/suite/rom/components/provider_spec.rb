# frozen_string_literal: true

require "rom/components/provider"

RSpec.describe ROM::Components::Provider do
  describe ".inherited" do
    it "imports components from the parent" do
      parent = Class.new do
        extend ROM.Provider(:dataset, type: :component)

        dataset(:ds) do
          %i[hello world]
        end
      end

      child = Class.new(parent)

      dataset = child.components.get(:datasets, id: :ds)

      expect(dataset).to be_abstract
      expect(dataset.id).to be(:ds)
    end

    # FIXME: running this spec causes other specs to randomly fail
    xit "allows defining anonymous multiple abstract components" do
      parent = Class.new do
        extend ROM.Provider(:gateway, :dataset, type: :component)

        config.component.adapter = :memory
        config.dataset.abstract = true

        gateway(:default)

        dataset do
          insert(:world)
        end

        dataset do
          insert(:hello)
        end
      end

      child = Class.new(parent) do
        dataset(id: :ds, abstract: false) do
          reverse
        end
      end

      expect(child.components.datasets.size).to be(3)

      dataset = child.components.get(:datasets, id: :ds)

      expect(dataset).to_not be_abstract
      expect(dataset.id).to be(:ds)
    end
  end
end
