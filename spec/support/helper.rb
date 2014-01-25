# encoding: utf-8

module SpecHelper

  def mock_model(*attributes, &block)
    model = Class.new {
      include Equalizer.new(*attributes)

      const_set(:ATTRIBUTES, attributes)

      attributes.each { |name| attr_accessor name }

      def initialize(attrs = {}, &block)
        attrs.each { |name, value| send("#{name}=", value) }
        instance_eval(&block) if block
      end

      def update(tuple)
        self.class.new(to_h.update(tuple))
      end

      def attribute_names
        self.class.const_get(:ATTRIBUTES)
      end

      def to_h
        attribute_names.each_with_object({}) { |name, h| h[name] = send(name) }
      end
    }
    model.class_eval(&block) if block
    model
  end

end
