# encoding: utf-8

module ROM
  class Mapping

    # Mapping definition DSL
    #
    # @private
    class Definition
      include Adamantium::Flat

      attr_reader :mapping, :attributes
      private :mapping, :attributes

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
        @header     = header
        @mapping    = {}
        @attributes = Set.new

        instance_eval(&block)

        build_mapper unless mapper
      end

      # @api private
      def header
        Mapper::Header.build(project_header, map: mapping)
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
        get_or_set(:mapper, mapper)
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
        get_or_set(:model, model)
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
        options = args.last

        if options.kind_of?(Hash)
          mapping.update(args.first => options[:to])
        else
          @attributes += Set[*args]
        end
      end

      private

      # Project header using configured attributes
      #
      # @api private
      def project_header
        @header.project(attributes + Set[*mapping.keys])
      end

      # Build default rom mapper
      #
      # @api private
      def build_mapper
        @mapper = Mapper.build(header, model)
      end

      def get_or_set(name, value)
        ivar = "@#{name}"
        if value == Undefined
          instance_variable_get(ivar)
        else
          instance_variable_set(ivar, value)
        end
      end

    end # Definition

  end # Mapping
end # ROM
