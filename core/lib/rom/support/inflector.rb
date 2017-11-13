require 'dry/inflector'

module ROM
  DOUBLE_COLON = '::'.freeze

  Inflector = Dry::Inflector.new

  def Inflector.constantize(input)
    names = input.split(DOUBLE_COLON)
    names.shift if names.first.empty?

    names.inject(Object) do |constant, name|
      if constant.const_defined?(name, false)
        constant.const_get(name)
      else
        constant.const_missing(name)
      end
    end
  end
end
