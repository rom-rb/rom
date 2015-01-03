module ROM
  class ClassBuilder
    attr_reader :options, :name, :parent

    def initialize(options)
      @options = options
      @name = options.fetch(:name)
      @parent = options.fetch(:parent)
    end

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
