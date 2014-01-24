# encoding: utf-8

module SpecHelper

  def mock_model(*attributes)
    Class.new {
      include Equalizer.new(*attributes)

      attributes.each { |attribute| attr_accessor attribute }

      def initialize(attrs)
        attrs.each { |name, value| send("#{name}=", value) }
      end
    }
  end

end
