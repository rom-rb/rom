module ROM
  module EnvironmentPlugins
    # Automatically registers relations, mappers and commands as they are defined
    #
    # For now this plugin is always enabled
    #
    # @api public
    module AutoRegistration
      # @api private
      def self.apply(environment)
        ROM::Relation.on(:inherited) { |relation| environment.register_relation(relation) }
        ROM::Command.on(:inherited) { |command| environment.register_command(command) }
        ROM::Mapper.on(:inherited) { |mapper| environment.register_mapper(mapper) }
      end
    end
  end
end
