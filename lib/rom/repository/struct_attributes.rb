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

          define_method(:assert_known_attributes) do |values|
            actual = values.keys
            unknown, missing = actual - attributes, attributes - actual

            if unknown.size > 0 || missing.size > 0
              raise ROM::Struct::InvalidAttributes.new(self.class, missing, unknown)
            end
          end
        end
      end

      def define_constructor(attributes)
        ivs = attributes.map { |a| "@#{a}" }.join(', ')
        values = attributes.map { |a| "values.fetch(:#{a})" }.join(', ')

        assignment = attributes.size > 0 ? "#{ivs} = #{values}" : EMPTY_STRING

        module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def initialize(values)
            assert_known_attributes(values) if values.size > #{attributes.size}
            #{assignment}
          rescue KeyError
            assert_known_attributes(values)
          end
        RUBY
      end
    end
  end
end
