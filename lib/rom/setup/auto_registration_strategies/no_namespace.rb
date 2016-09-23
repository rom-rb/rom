module ROM
  module AutoRegistrationStrategies
    class NoNamespace < Base
      option :directory, reader: true, type: Pathname
      option :entity, reader: true, type: Symbol

      def call
        Inflector.camelize(
          file.sub(/^#{directory}\/#{entity}\//, '').sub(EXTENSION_REGEX, '')
        )
      end
    end
  end
end
