require 'rom/adapter/memory/commands'

module ROM
  class Adapter

    class Memory < Adapter
      attr_reader :connection

      attr_accessor :logger

      def self.schemes
        [:memory]
      end

      class Dataset
        include Charlatan.new(:data)

        def to_ary
          data.dup
        end
        alias_method :to_a, :to_ary

        def each(&block)
          return to_enum unless block
          data.each(&block)
        end

        def restrict(criteria = nil, &block)
          if criteria
            find_all { |tuple| criteria.all? { |k, v| tuple[k] == v } }
          else
            find_all { |tuple| yield(tuple) }
          end
        end

        def project(*names)
          map { |tuple| tuple.reject { |key,_| names.include?(key) } }
        end

        def order(*names)
          sort_by { |tuple| tuple.values_at(*names) }
        end

        def insert(tuple)
          data << tuple
          self
        end

        def delete(tuple)
          data.delete(tuple)
          self
        end

        def header
          []
        end
      end

      class Storage
        attr_reader :data

        def initialize(*)
          super
          @data = {}
        end

        def [](name)
          data[name] ||= Dataset.new([])
        end
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
          when :create then Commands::Create
          when :update then Commands::Update
          when :delete then Commands::Delete
          else
            raise ArgumentError, "#{type.inspect} is not a supported command type"
          end

        if type == :create
          klass.new(relation, definition.to_h)
        elsif type == :update
          klass.build(relation, definition)
        else
          klass.build(relation)
        end
      end

      Adapter.register(self)
    end

  end
end
