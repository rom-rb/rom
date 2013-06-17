module ROM
  class Schema
    class Definition

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
          @keys << attribute_names
          self
        end

      end # class Relation

    end # class Definition
  end # class Schema
end # module ROM
