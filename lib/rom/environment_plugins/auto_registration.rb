module ROM
  module EnvironmentPlugins
    # Automatically registers relations, mappers and commands as they are defined
    #
    # For now this plugin is always enabled
    #
    # @api public
    module AutoRegistration
      # Say "yes" for envs that have this plugin enabled
      #
      # By default it says "no" in Environment#auto_registration?
      #
      # @api private
      def auto_registration?
        true
      end

      # @api private
      def self.apply(environment, options = {})
        environment.extend(AutoRegistration)

        if_proc = options.fetch(:if, ->(*args) { true })

        ROM::Relation.on(:inherited) do |relation|
          environment.register_relation(relation) if if_proc.call(relation)
        end

        ROM::Command.on(:inherited) do |command|
          environment.register_command(command) if if_proc.call(command)
        end

        ROM::Mapper.on(:inherited) do |mapper|
          environment.register_mapper(mapper) if if_proc.call(mapper)
        end
      end
    end
  end
end
