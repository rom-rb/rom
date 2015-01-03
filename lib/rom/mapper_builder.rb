require 'rom/mapper_builder/model_dsl'
require 'rom/mapper_builder/mapper_dsl'

module ROM
  # @api private
  class MapperBuilder
    include Options

    option :parent, type: Symbol
    option :prefix, reader: true
    option :symbolize_keys, reader: true, allow: [true, false]
    option :inherit_header, allow: [true, false]

    attr_reader :name, :root, :dsl

    DEFAULT_PROCESSOR = :transproc

    def initialize(name, root, options = {})
      super

      @name = name
      @root = root

      attributes =
        if options[:inherit_header]
          root.header.map { |attr| [prefix ? :"#{prefix}_#{attr}" : attr] }
        else
          []
        end

      @dsl = MapperDSL.new(attributes, options)

      @processor = DEFAULT_PROCESSOR
    end

    def processor(identifier = nil)
      if identifier
        @processor = identifier
      else
        @processor
      end
    end

    def call
      Mapper.build(dsl.header, processor)
    end

    private

    def method_missing(name, *args, &block)
      if dsl.respond_to?(name)
        dsl.public_send(name, *args, &block)
      else
        super
      end
    end
  end
end
