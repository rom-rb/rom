# encoding: utf-8

module ROM
  class Mapping

    # @private
    class Definition
      include Adamantium::Flat

      attr_reader :mapping, :attributes
      private :mapping, :attributes

      # @api private
      def self.build(header, &block)
        new(header, &block)
      end

      # @api private
      def initialize(header, &block)
        @header     = header
        @mapping    = {}
        @attributes = Set.new
        @mapper     = nil
        @model      = nil
        instance_eval(&block)
      end

      # @api private
      def header
        Mapper::Header.build(project_header, map: mapping)
      end
      memoize :header

      # @api private
      def mapper(mapper = Undefined)
        if mapper == Undefined
          @mapper
        else
          @mapper = mapper
        end
      end

      # @api private
      def model(model = Undefined)
        if model == Undefined
          @model
        else
          @model = model
        end
      end

      # @api private
      def map(*args)
        options = args.last

        if options.kind_of?(Hash)
          mapping.update(args.first => options[:to])
        else
          @attributes += Set[*args]
        end

        self
      end

      private

      # @api private
      def project_header
        @header.project(attributes + Set[*mapping.keys])
      end

    end # Definition

  end # Mapping
end # ROM
