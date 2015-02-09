module ROM
  class Relation
    # @api private
    def self.build_class(name, options = {})
      class_name = "ROM::Relation[#{Inflecto.camelize(name)}]"
      adapter = options.fetch(:adapter)

      ClassBuilder.new(name: class_name, parent: self[adapter]).call do |klass|
        klass.repository(options.fetch(:repository) { :default })
        klass.dataset(name)
      end
    end
  end
end
