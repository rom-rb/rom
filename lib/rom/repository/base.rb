require 'rom/support/options'

require 'rom/repository/mapper_builder'
require 'rom/repository/loading_proxy'

module ROM
  class Repository < Gateway
    # Abstract repository class to inherit from
    #
    # TODO: rename this to Repository once deprecated Repository from rom core is gone
    #
    # @api public
    class Base # :trollface:
      include Options

      option :mapper_builder, reader: true, default: proc { MapperBuilder.new }

      # Define which relations your repository is going to use
      #
      # @example
      #   class MyRepo < ROM::Repository::Base
      #     relations :users, :tasks
      #   end
      #
      #   my_repo = MyRepo.new(rom_env)
      #
      #   my_repo.users
      #   my_repo.tasks
      #
      # @return [Array<Symbol>]
      #
      # @api public
      def self.relations(*names)
        if names.any?
          attr_reader(*names)
          @relations = names
        else
          @relations
        end
      end

      # @api private
      def initialize(env, options = {})
        super
        self.class.relations.each do |name|
          proxy = LoadingProxy.new(
            env.relation(name), name: name, mapper_builder: mapper_builder
          )
          instance_variable_set("@#{name}", proxy)
        end
      end
    end
  end
end
