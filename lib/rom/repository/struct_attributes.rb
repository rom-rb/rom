module ROM
  class Repository
    # @api private
    class StructAttributes < Module
      def initialize(attributes)
        super()

        define_constructor(attributes)

        module_eval do
          include Dry::Equalizer.new(*attributes)

          attr_reader(*attributes)

          define_method(:to_h) do
            attributes.each_with_object({}) do |attribute, h|
              h[attribute] = __send__(attribute)
            end
          end
        end
      end

      def define_constructor(attributes)
        module_eval do
          def __missing_keyword__(keyword)
            raise ArgumentError.new("missing keyword: #{keyword}")
          end
          private :__missing_keyword__
        end

        kwargs = attributes.map { |a| "#{a}: __missing_keyword__(:#{a})" }.join(', ')

        ivs = attributes.map { |a| "@#{a}" }.join(', ')
        values = attributes.join(', ')

        assignment = attributes.size > 0 ? "#{ivs} = #{values}" : EMPTY_STRING

        module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def initialize(#{kwargs})
            #{assignment}
          end
        RUBY
      end
    end
  end
end
