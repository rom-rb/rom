# encoding: utf-8

module ROM
  class Mapper

    class Mapping

      attr_reader :model
      attr_reader :header

      def initialize(model, header = EMPTY_ARRAY, &block)
        @model   = model
        @header  = header.dup
        instance_eval(&block) if block
      end

      def map(name, type = Undefined)
        add(Attribute::Simple, name, type)
      end

      def wrap(name, type, &block)
        add(Attribute::EmbeddedValue, name, type)
      end

      def group(name, type, &block)
        add(Attribute::EmbeddedCollection, name, type)
      end

      private

      def add(attribute, name, type)
        header << attribute.new(name, type)
      end
    end # Mapping
  end # Mapper
end # ROM
