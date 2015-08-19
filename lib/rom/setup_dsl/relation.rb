module ROM
  # Setup DSL-specific relation extensions
  #
  # @private
  class Relation
    # Generate a relation subclass
    #
    # This is used by Setup#relation DSL
    #
    # @api private
    def self.build_class(name, options = EMPTY_HASH)
      class_name = "ROM::Relation[#{Inflector.camelize(name)}]"
      adapter = options.fetch(:adapter)

      ClassBuilder.new(name: class_name, parent: self[adapter]).call do |klass|
        klass.gateway(options.fetch(:gateway) {
          if options.key?(:repository)
          ROM::Deprecations.announce "The :repository key is", <<-MSG
            Please use `gateway: :#{options.fetch(:repository)}` instead.
          MSG
            options.fetch(:repository)
          else
            :default
          end
        })
        klass.dataset(name)
      end
    end
  end
end
