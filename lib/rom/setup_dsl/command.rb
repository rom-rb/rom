module ROM
  class Command
    def self.build_class(name, relation, options = {}, &block)
      type = options.fetch(:type) { name }
      command_type = Inflecto.classify(type)
      adapter = options.fetch(:adapter)
      parent = adapter_namespace(adapter).const_get(command_type)
      class_name = generate_class_name(adapter, command_type, relation)

      ClassBuilder.new(name: class_name, parent: parent).call do |klass|
        klass.register_as(name)
        klass.relation(relation)
        klass.class_eval(&block) if block
      end
    end

    def self.generate_class_name(adapter, command_type, relation)
      pieces = ['ROM']
      pieces << Inflecto.classify(adapter)
      pieces << 'Commands'
      pieces << "#{command_type}[#{Inflecto.classify(relation)}s]"
      pieces.join('::')
    end
  end
end
