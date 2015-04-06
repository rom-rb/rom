require 'rom/support/registry'

module ROM

  class PluginRegistry
    attr_reader :commands, :mappers, :relations

    def initialize
      @mappers    = InternalPluginRegistry.new
      @commands   = InternalPluginRegistry.new
      @relations  = InternalPluginRegistry.new
    end

    def register(name, mod, options = {})
      type = options.fetch(:type)

      plugins_for(type)[name] = Plugin.new(mod, options)
    end

    private

    def plugins_for(type)
      case type
      when :command   then commands
      when :mapper    then mappers
      when :relation  then relations
      end
    end
  end


  class InternalPluginRegistry < Registry

    def []=(name, mod)
      elements[name] = mod
    end

    def [](name)
      elements.fetch(name) { raise(UnknownPluginError, name) }
    end

  end



end
