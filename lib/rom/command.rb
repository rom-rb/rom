require 'rom/commands/abstract'

module ROM
  class Command < Commands::Abstract
    extend DescendantsTracker
    extend ClassMacros

    include Equalizer.new(:relation, :options)

    defines :relation, :result, :input, :validator, :register_as

    input Hash
    validator proc {}
    result :many

    def self.[](adapter)
      adapter_namespace(adapter).const_get(Inflecto.demodulize(name))
    end

    def self.adapter_namespace(adapter)
      ROM.adapters.fetch(adapter).const_get(:Commands)
    end

    def self.build(relation, options = {})
      new(relation, self.options.merge(options))
    end

    def self.registry(relations, repositories)
      Command.descendants.each_with_object({}) do |klass, h|
        rel_name = klass.relation

        next unless rel_name

        relation = relations[rel_name]
        name = klass.register_as || klass.default_name

        repository = repositories[relation.class.repository]
        repository.extend_command_class(klass, relation.dataset)

        (h[rel_name] ||= {})[name] = klass.build(relation)
      end
    end

    def self.default_name
      Inflecto.underscore(Inflecto.demodulize(name)).to_sym
    end

    def self.options
      { input: input, validator: validator, result: result }
    end
  end
end
