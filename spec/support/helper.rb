# encoding: utf-8

module SpecHelper

  def mock_model(*attributes)
    Class.new {
      include Equalizer.new(*attributes)

      attributes.each { |attribute| attr_accessor attribute }

      def initialize(attrs = {}, &block)
        attrs.each { |name, value| send("#{name}=", value) }
        instance_eval(&block) if block
      end
    }
  end

end
