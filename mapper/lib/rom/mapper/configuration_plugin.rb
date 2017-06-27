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

      class DSL < Module
        def initialize(options)
          @options = options
          define_module
        end

        def define_module
          module_exec(@options) do |options|
            define_method(:mappers) do |&block|
              register_mapper(*MapperDSL.new(mapper_classes, options, block).mapper_classes)
            end
          end
        end
      end

      def self.apply(configuration, options = {})
        configuration.extend DSL.new(options)
        configuration
      end
    end
  end
end
