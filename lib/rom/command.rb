require 'rom/commands'

module ROM
  class Command < Commands::AbstractCommand
    include Equalizer.new(:relation, :options)

    extend DescendantsTracker
    extend ClassMacros

    defines :type, :relation, :repository, :input, :validator, :result, :register_as

    repository :default
    result :many

    def self.adapter(name = nil)
      return @adapter unless name

      unless type
        raise ArgumentError, "#{self}.type must be specified before `adapter`"
      end

      commands = ROM.adapters.fetch(name).const_get(:Commands)
      mod = command_mod(commands)

      include(mod)

      @adapter = name

      self
    end

    def self.command_mod(commands)
      case type
      when :create then commands.const_get(:Create)
      when :update then commands.const_get(:Update)
      when :delete then commands.const_get(:Delete)
      else
        raise(
          ArgumentError,
          "#{type.inspect} is not a supported command type for #{inspect}"
        )
      end
    end

    def self.build(relation, options = {})
      new(relation, self.options.merge(options))
    end

    def self.registry(relations, repositories = {})
      Command.descendants.each_with_object({}) do |klass, h|
        rel_name = klass.relation
        relation = relations[rel_name]
        repository = repositories[relation.repository]

        name = klass.register_as || klass.type

        unless klass.adapter
          klass.send(:include, klass.command_mod(repository.command_namespace))
        end

        (h[rel_name] ||= {})[name] = klass.build(relation)
      end
    end

    def self.options
      { input: input, validator: validator, result: result }
    end
  end
end
