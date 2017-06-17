require 'dry/core/deprecations'
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
        msg = <<-STR
          Key inference will be removed in rom 4.0. You need to define :#{key} association.
            => Called at:
               #{caller.join("\n")}
          STR

        Dry::Core::Deprecations.warn(msg)

        false
      end
    end

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
