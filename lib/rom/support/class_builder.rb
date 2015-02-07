module ROM
  class ClassBuilder
    include Options

    option :name, type: String, reader: true
    option :parent, type: Class, reader: true, parent: Object

    def call
      klass = Class.new(parent)

      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.name
          #{name.inspect}
        end

        def self.inspect
          name
        end

        def self.to_s
          name
        end
      RUBY

      yield(klass) if block_given?

      klass
    end
  end
end
