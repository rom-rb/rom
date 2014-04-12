# encoding: utf-8

module ROM
  class Mapper
    class Builder

      # Mapping definition DSL
      #
      # @private
      class Definition
        include Adamantium::Flat

        attr_reader :name, :attributes, :mapper

        LOADERS = [:instance_variables, :attribute_hash, :attribute_accessors].freeze

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
        def initialize(name, &block)
          @name = name
          @attributes = []
          @loader = :load_instance_variables

          instance_eval(&block)
        end

        # @api private
        def options
          { model: model, type: loader }
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
        def mapper(mapper = Undefined)
          if mapper == Undefined
            @mapper
          else
            warn "setting mapper inside mapping block is deprecated - use relation(#{name.inspect}, your_mapper) instead (#{caller[0]})"
            @mapper = mapper
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
          if args.last.is_a?(Hash)
            @attributes << args
          else
            @attributes.concat(args.zip)
          end
        end

      end # Definition

    end # DSL
  end # Mapper
end # ROM
