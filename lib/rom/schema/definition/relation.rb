module ROM
  class Schema
    class Definition

      # Builder object for Axiom relation
      #
      class Relation
        include Equalizer.new(:header, :keys)

        def initialize(&block)
          @header = []
          @keys   = []
          instance_eval(&block) if block
        end

        def header
          Axiom::Relation::Header.coerce(@header, :keys => @keys)
        end

        def attribute(name, type)
          @header << [name, type]
          self
        end

        def key(*attribute_names)
          @keys.concat(attribute_names)
          self
        end

      end # Relation

    end # Definition
  end # Schema
end # ROM
