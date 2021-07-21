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
  end
end
