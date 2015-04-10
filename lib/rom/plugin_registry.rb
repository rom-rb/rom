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
      type    = options.fetch(:type)
      adapter = options.fetch(:adapter, :default)

      plugins_for(type, adapter)[name] = Plugin.new(mod, options)
    end

    private

    def plugins_for(type, adapter)
      case type
      when :command   then commands.adapter(adapter)
      when :mapper    then mappers.adapter(adapter)
      when :relation  then relations.adapter(adapter)
      end
    end
  end

  class AdapterPluginRegistry < Registry

    def []=(name, mod)
      elements[name] = mod
    end

    def [](name)
      elements[name]
    end

  end

  class InternalPluginRegistry
    attr_reader :registries

    def initialize
      @registries = Hash.new{|h,v| h[v] = AdapterPluginRegistry.new }
    end

    def adapter(name)
      registries[name]
    end

    def fetch(name, adapter = :default)
      registries[adapter][name] || registries[:default][name] ||
        raise(UnknownPluginError, name) 
    end

    alias [] fetch
  end



end
