require 'rom/mapper_builder/model_dsl'
require 'rom/mapper_builder/mapper_dsl'

module ROM
  # @api private
  class MapperBuilder
    attr_reader :name, :root, :options, :prefix, :symbolize_keys, :dsl

    DEFAULT_PROCESSOR = :transproc

    def initialize(name, root, options = {})
      @name = name
      @options = options
      @root = root
      @prefix = options[:prefix]
      @symbolize_keys = options[:symbolize_keys]

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
