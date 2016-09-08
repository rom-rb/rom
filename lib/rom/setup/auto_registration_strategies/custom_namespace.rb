module ROM
  module AutoRegistrationStrategies
    class CustomNamespace < Base
      option :namespace, reader: true, type: String

      def call
        "#{namespace}::#{Inflector.camelize(filename).sub(EXTENSION_REGEX, '')}"
      end

      private

      def filename
        Pathname.new(file).basename.to_s
      end
    end
  end
end
