require 'rom/adapter/memory/storage'
require 'rom/adapter/memory/dataset'
require 'rom/adapter/memory/commands'

module ROM
  class Adapter

    class Memory < Adapter
      attr_reader :connection

      attr_accessor :logger

      def self.schemes
        [:memory]
      end

      def initialize(*args)
        super
        @connection = Storage.new
      end

      def [](name)
        connection[name]
      end

      def command(name, relation, definition)
        type = definition.type || name

        klass =
          case type
          when :create then Memory::Commands::Create
          when :update then Memory::Commands::Update
          when :delete then Memory::Commands::Delete
          else
            raise ArgumentError, "#{type.inspect} is not a supported command type"
          end

        if type == :create || type == :update
          klass.new(relation, definition.to_h)
        else
          klass.build(relation)
        end
      end

      Adapter.register(self)
    end

  end
end
