require 'rom/mapper_builder/model_dsl'
require 'rom/mapper_builder/mapper_dsl'

module ROM
  # @api private
  class MapperBuilder
    include ModelDSL

    attr_reader :name, :root, :options, :prefix, :symbolize_keys, :attributes

    DEFAULT_PROCESSOR = :transproc

    def initialize(name, root, options = {})
      @name = name
      @options = options
      @root = root
      @prefix = options[:prefix]
      @symbolize_keys = options[:symbolize_keys]

      @attributes =
        if options[:inherit_header]
          root.header.map { |attr| [prefix ? :"#{prefix}_#{attr}" : attr] }
        else
          []
        end

      @processor = DEFAULT_PROCESSOR

      super
    end

    def processor(identifier = nil)
      if identifier
        @processor = identifier
      else
        @processor
      end
    end

    def exclude(name)
      attributes.delete([name])
    end

    def call
      header = Header.coerce(attributes, model)
      Mapper.build(header, processor)
    end

    private

    def method_missing(name, *args, &block)
      if MapperDSL.public_instance_methods.include?(name)
        attribute_dsl(name, *args, &block)
      else
        super
      end
    end

    def attribute_dsl(method, *args, &block)
      dsl = MapperDSL.new(options)
      dsl.public_send(method, *args, &block)
      add_attributes(dsl.attributes)
    end

    def add_attributes(attrs)
      Array(attrs).each do |attr|
        exclude(attr.first.to_s)
        exclude(attr.first)
        exclude(attr.last[:from])
        attributes << attr
      end
    end
  end
end
