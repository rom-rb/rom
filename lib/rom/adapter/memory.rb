module ROM
  class Adapter

    class Memory < Adapter
      attr_reader :connection

      module Commands
        class Create
          include Concord.new(:relation, :input, :validator)

          def execute(tuple)
            attributes = input.new(tuple)
            validation = validator.call(attributes)

            if validation.success?
              result = relation.insert(attributes.to_h)
              [result.to_a.last]
            else
              validation
            end
          end
        end

        class Update
          include Concord.new(:relation, :input, :validator)

          def execute(params)
            attributes = input.new(params)

            relation.map do |tuple|
              validation = validator.call(attributes)

              if validation.success?
                tuple.update(attributes.to_h)
              else
                validation
              end
            end
          end

          def new(*args, &block)
            self.class.new(relation.public_send(*args, &block), input, validator)
          end
        end
      end

      def self.schemes
        [:memory]
      end

      class Dataset
        include Charlatan.new(:data)

        def to_ary
          data
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
        klass =
          case name
          when :create then Commands::Create
          when :update then Commands::Update
          else
            raise ArgumentError, "#{name.inspect} is not a supported command type"
          end

        klass.new(relation, definition.input, definition.validator)
      end

      Adapter.register(self)
    end

  end
end
