module ROM
  class Command
    def self.build_class(name, relation, options = {}, &block)
      type = options.fetch(:type) { name }
      class_name = "ROM::Command[#{relation}][#{type}]"
      adapter = options.fetch(:adapter)
      parent = adapter_namespace(adapter).const_get(Inflecto.classify(type))

      ClassBuilder.new(name: class_name, parent: parent).call do |klass|
        klass.register_as(name)
        klass.relation(relation)
        klass.class_eval(&block) if block
      end
    end
  end
end
