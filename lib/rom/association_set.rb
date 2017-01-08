require 'dry/core/inflector'
require 'rom/registry'

module ROM
  class AssociationSet < ROM::Registry
    # @api private
    def try(name, &block)
      key = name.to_sym

      if key?(key) || key?(singularize(key))
        yield(self[key])
      else
        false
      end
    end

    # @api private
    def [](name)
      key = name.to_sym

      if key?(key)
        super
      else
        super(singularize(key))
      end
    end

    def singularize(key)
      Dry::Core::Inflector.singularize(key).to_sym
    end
  end
end
