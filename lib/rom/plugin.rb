module ROM
  # Plugin is a simple object used to store plugin configurations
  #
  # @private
  class Plugin
    # @return [Module] a module representing the plugin
    #
    # @api private
    attr_reader :mod

    # @return [Hash] configuration options
    #
    # @api private
    attr_reader :options

    # @api private
    def initialize(mod, options)
      @mod      = mod
      @options  = options
    end

    # Apply this plugin to the provided class
    #
    # @param klass [Class]
    #
    # @api private
    def apply_to(klass)
      klass.send(:include, mod)
    end
  end
end
