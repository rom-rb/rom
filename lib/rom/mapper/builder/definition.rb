# encoding: utf-8

module ROM
  class Mapper
    class Builder

      # Mapping definition DSL
      #
      # @private
      class Definition
        include Adamantium::Flat

        attr_reader :attributes

        LOADERS = [:instance_variables, :attribute_hash, :attribute_writers].freeze

        # Build new mapping definition
        #
        # @api private
        def self.build(header, &block)
          new(header, &block)
        end

        # Initialize a new Definition instance
        #
        # @return [undefined]
        #
        # @api private
        def initialize(header, &block)
          @header = header
          @keys = header.keys.flat_map { |key_header| key_header.flat_map(&:name) }
          @attributes = []
          @loader = :load_instance_variables

          instance_eval(&block)

          build_mapper unless mapper
        end

        # @api private
        def attribute_names
          attributes.map(&:name)
        end

        # @api private
        def loader(name = Undefined)
          if name == Undefined
            @loader
          else
            unless LOADERS.include?(name)
              raise ArgumentError,
                "loader +#{name.inspect}+ is not known. Valid loaders are #{LOADERS.inspect}"
            end

            @loader = :"load_#{name}"
          end
        end

        # @api private
        def header
          @header.project(attributes.map(&:name))
        end
        memoize :header

        # Get or set mapper
        #
        # @example
        #
        #   Mapping.build do
        #     users do
        #       mapper my_custom_mapper
        #     end
        #   end
        #
        # @param [Object]
        #
        # @return [Object]
        #
        # @api public
        def mapper(mapper = Undefined)
          if mapper == Undefined
            @mapper
          else
            @mapper = mapper
          end
        end

        # Get or set model for the mapper
        #
        # @example
        #
        #   Mapping.build do
        #     users do
        #       model User
        #     end
        #   end
        #
        # @param [Class]
        #
        # @return [Class]
        #
        # @api public
        def model(model = Undefined)
          if model == Undefined
            @model
          else
            @model = model
          end
        end

        # Configure attribute mappings
        #
        # @example
        #
        #   Mapping.build do
        #     users do
        #       map :id, :email
        #       map :user_name, to: :name
        #     end
        #   end
        #
        # @params [Array<Symbol>,Symbol,Hash]
        #
        # @return [Definition]
        #
        # @api public
        def map(*args)
          if args.last.kind_of?(Hash)
            attributes.concat([build_attribute(*args)])
          else
            attributes.concat(args.map { |name| build_attribute(name) })
          end
        end

        private

        # Build default rom mapper
        #
        # @api private
        def build_mapper
          @mapper = Mapper.build(attributes, model: model, loader: loader)
        end

        def build_attribute(name, options = {})
          header_name = options.fetch(:from, name)

          defaults = {
            key: @keys.include?(header_name),
            type: @header[header_name].type.primitive
          }

          Attribute.build(name, defaults.merge(options))
        end

      end # Definition

    end # DSL
  end # Mapper
end # ROM
