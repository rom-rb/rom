module ROM
  class Processor
    class Transproc < Processor
      class CombinedAttribute
        def initialize(attribute)
          @attribute = attribute
        end

        def to_transproc_args
          [@attribute.name, @attribute.meta[:keys], children].compact
        end

        private

        def children
          has_children? ? other.map { |child| CombinedAttribute.new(child).to_transproc_args } : nil
        end

        def has_children?
          other.any?
        end

        def other
          @attribute.header.combined
        end
      end
    end
  end
end