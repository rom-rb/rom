require 'rom/support/options'

require 'rom/repository/ext/relation'

require 'rom/repository/mapper_builder'
require 'rom/repository/loading_proxy'

module ROM
  class Repository < Gateway
    class Base # :trollface:
      include Options

      option :mapper_builder, reader: true, default: proc { MapperBuilder.new }

      def self.relations(*names)
        if names.any?
          attr_reader(*names)
          @relations = names
        else
          @relations
        end
      end

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
