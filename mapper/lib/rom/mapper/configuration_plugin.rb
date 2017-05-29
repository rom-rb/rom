require 'rom/mapper/mapper_dsl'

module ROM
  class Mapper
    # Model DSL allows setting a model class
    #
    # @private
    module ConfigurationPlugin
      # Mapper definition DSL used by Setup DSL
      #
      # @private

      def self.apply(configuration, options = {})
        configuration.class.class_eval do
          def mappers(&block)
            register_mapper(*MapperDSL.new(self, mapper_classes, block).mapper_classes)
          end
        end
        configuration
      end
    end
  end
end
