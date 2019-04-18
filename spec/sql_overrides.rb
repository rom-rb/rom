require "rom"
require "rom-sql"

# Overrides to be done in rom-sql
module ROM
  module SQL
    class Schema < ROM::Schema
      class AttributesInferrer
        def call(schema, gateway)
          dataset = schema.name.dataset

          columns = filter_columns(gateway.connection.schema(dataset))

          inferred = columns.map do |(name, definition)|
            type = type_builder.(definition)

            attr_class.new(type.meta(source: schema.name), name: name) if type
          end.compact

          missing = columns.map(&:first) - inferred.map { |attr| attr.name }

          [inferred, missing]
        end
      end
    end

    class Attribute < ROM::Attribute
      def aliased(name)
        super.meta(sql_expr: sql_expr.as(name))
      end
      alias_method :as, :aliased
    end

    class Function < ROM::Attribute
      def name
        self.alias || super
      end
    end
  end
end