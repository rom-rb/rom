module ROM
  module ConfigurationPlugins
    # Automatically registers relations, mappers and commands as they are defined
    #
    # For now this plugin is always enabled
    #
    # @api public
    module AutoRegistration
      module ClassMethods
        # Say "yes" for envs that have this plugin enabled
        #
        # By default it says "no" in Configuration#auto_registration?
        #
        # @api private
        def auto_registration?
          true
        end
      end

      class ClassTrapper
        def initialize klass, &block
          @klass = klass
          @block = block
          klass.on(self, {scope: klass})
        end

        def inherited(object)
          @block.call(object)
        end
      end

      class Trapper
        attr_reader :relations, :commands, :mappers

        def initialize
          @relations = []
          @commands = []
          @mappers = []
          @trappers = []

          @trappers << ClassTrapper.new(ROM::Relation) { |relation| @relations << relation }
          @trappers << ClassTrapper.new(ROM::Command) { |command| @commands << command }
          @trappers << ClassTrapper.new(ROM::Mapper) { |mapper| @mappers << mapper }
        end

        def register_on(config, if_proc)
          @relations.each { |rel| config.register_relation(rel) if if_proc.call(rel) }
          @commands.each { |com| config.register_command(com) if if_proc.call(com) }
          @mappers.each { |map| config.register_mapper(map) if if_proc.call(map) }
        end
      end

      class << self
        # @api private
        def apply(configuration, options = {})
          configuration.extend(ClassMethods)

          if_proc = options.fetch(:if, ->(*args) { true })

          @trapper.register_on(configuration, if_proc) if options.fetch(:retroactive, true)

          ROM::Relation.on(:inherited) do |relation|
            configuration.register_relation(relation) if if_proc.call(relation)
          end

          ROM::Command.on(:inherited) do |command|
            configuration.register_command(command) if if_proc.call(command)
          end

          ROM::Mapper.on(:inherited) do |mapper|
            configuration.register_mapper(mapper) if if_proc.call(mapper)
          end
        end

        def reset_trapper
          @trapper = Trapper.new
        end
      end

      reset_trapper
    end
  end
end
