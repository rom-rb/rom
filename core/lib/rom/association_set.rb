require 'dry/core/inflector'
require 'rom/registry'

module ROM
  class AssociationSet < ROM::Registry
    # @api private
    def [](name)
      key = name.to_sym

      if key?(key)
        super
      else
        sk = singularize(key)

        if key?(sk)
          super(sk)
        else
          super
        end
      end
    end

    # @api private
    def singularize(key)
      Dry::Core::Inflector.singularize(key).to_sym
    end
  end
end
