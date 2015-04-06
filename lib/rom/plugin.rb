module ROM

  class Plugin

    attr_reader :mod, :options

    def initialize(mod, options)
      @mod      = mod
      @options  = options
    end


    def apply_to(klass)
      klass.send(:include, mod)
    end

  end

end
