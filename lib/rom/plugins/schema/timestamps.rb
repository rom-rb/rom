# frozen_string_literal: true

module ROM
  module Plugins
    module Schema
      # A plugin for automatically adding timestamp fields
      # to the schema definition
      #
      # @example
      #   schema do
      #     use :timestamps
      #   end
      #
      #   # using non-default names
      #   schema do
      #     use :timestamps, attributes: %i(created_on updated_on)
      #   end
      #
      #   # using other types
      #   schema do
      #     use :timestamps, type: Types::Date
      #   end
      #
      # @api public
      module Timestamps
        DEFAULT_TIMESTAMPS = %i[created_at updated_at].freeze
        DEFAULT_TYPE = ROM::Types::Time

        # @api private
        def self.apply(schema, **options)
          attributes = options.fetch(:attributes, DEFAULT_TIMESTAMPS)
          attrs_type = options.fetch(:type, DEFAULT_TYPE)

          attributes.each do |name|
            schema.attribute(name, attrs_type)
          end

          schema
        end

        # @api private
        module DSL
          # Sets non-default timestamp attributes
          #
          # @example
          #   schema do
          #     use :timestamps
          #     timestamps :create_on, :updated_on
          #   end
          #
          # @api public
          def timestamps(*names)
            plugin(:timestamps).config.update(attributes: names)
          end
        end
      end
    end
  end
end
