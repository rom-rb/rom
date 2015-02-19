module ROM
  # Helper module providing thin interface around an inflection backend.
  #
  # @private
  module Inflector
    BACKENDS = {
      activesupport: [
        'active_support/inflector',
        proc { ::ActiveSupport::Inflector }
      ],
      inflecto: [
        'inflecto',
        proc { ::Inflecto }
      ]
    }.freeze

    def self.realize_backend(path, inflector_backend_factory)
      require path
      inflector_backend_factory.call
    rescue LoadError
      nil
    end

    def self.detect_backend
      BACKENDS.find do |_, (path, inflector_class)|
        backend = realize_backend(path, inflector_class)
        break backend if backend
      end ||
        raise(LoadError,
              "No inflector library could be found: "\
              "please install either the `inflecto` or `activesupport` gem.")
    end

    def self.select_backend(name = nil)
      if name && !BACKENDS.key?(name)
        raise NameError, "Invalid inflector library selection: '#{name}'"
      end
      @inflector = name ? realize_backend(*BACKENDS[name]) : detect_backend
    end

    def self.inflector
      @inflector || select_backend
    end

    def self.camelize(input)
      inflector.camelize(input)
    end

    def self.underscore(input)
      inflector.underscore(input)
    end

    def self.singularize(input)
      inflector.singularize(input)
    end

    def self.pluralize(input)
      inflector.pluralize(input)
    end

    def self.demodulize(input)
      inflector.demodulize(input)
    end

    def self.constantize(input)
      inflector.constantize(input)
    end

    def self.classify(input)
      inflector.classify(input)
    end
  end
end
