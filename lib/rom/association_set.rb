require 'dry/core/inflector'
require 'rom/registry'

module ROM
  class AssociationSet < ROM::Registry
    # @api private
    def try(name, &block)
      if key?(name)
        yield(self[name])
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
        super(Dry::Core::Inflector.singularize(key))
      end
    end
  end
end
