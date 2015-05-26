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
    def self.build_class(name, options = {})
      class_name = "ROM::Relation[#{Inflector.camelize(name)}]"
      adapter = options.fetch(:adapter)

      ClassBuilder.new(name: class_name, parent: self[adapter]).call do |klass|
        klass.gateway(options.fetch(:gateway) {
          if options.key?(:repository)
          warn <<-MSG.gsub(/^\s+/, '')
            The repository key is deprecated and will be removed in 1.0.0.
            Please use `gateway: :#{options.fetch(:repository)}` instead.
            #{caller.detect { |l| !l.include?('lib/rom')}}
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
