# frozen_string_literal: true

require "rom/components/provider"

RSpec.describe ROM::Components::Provider do
  describe ".inherited" do
    it "imports components from the parent" do
      module Test
        class Parent
          extend ROM.Provider(:dataset, type: :component)

          dataset(id: :ds) do
            %i[hello world]
          end
        end

        class Child < Parent
        end
      end

      dataset = Test::Child.components.get(:datasets, id: :ds)

      expect(dataset).to be_abstract
      expect(dataset.id).to be(:ds)

      expect(Test::Child.resolver.datasets[:ds]).to eql(%i[hello world])
    end

    # FIXME: running this spec causes other specs to randomly fail
    xit "allows defining anonymous multiple abstract components" do
      module Test
        class Parent
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

        class Child < Parent
          dataset(id: :ds, abstract: false) do
            reverse
          end
        end
      end

      expect(Test::Child.components.datasets.size).to be(3)

      dataset = Test::Child.components.get(:datasets, id: :ds)

      expect(dataset).to_not be_abstract
      expect(dataset.id).to be(:ds)

      expect(Test::Child.resolver.datasets[:ds]).to eql(%i[hello world])
    end
  end
end
