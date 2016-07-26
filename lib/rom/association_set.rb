require 'rom/support/registry'
require 'rom/support/inflector'

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
        super(Inflector.singularize(key))
      end
    end
  end
end
