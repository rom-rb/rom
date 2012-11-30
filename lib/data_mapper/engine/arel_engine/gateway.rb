module DataMapper
  class Engine
    class ArelEngine < self

      class Gateway
        include Enumerable

        attr_reader :name
        attr_reader :header
        attr_reader :engine
        attr_reader :relation

        def initialize(engine, relation, name = nil, header = nil)
          @engine   = engine
          @relation = relation
          @header   = relation.respond_to?(:columns) ? relation.columns : header
          @name     = relation.respond_to?(:name) ? relation.name : name
        end

        def each(&block)
          return to_enum unless block_given?
          read.each(&block)
          self
        end

        def new(relation, header = @header)
          self.class.new(engine, relation, name, header)
        end

        def restrict(*args)
          new(relation.where(*args))
        end

        def insert(tuple)
          binds = tuple.to_a.map { |a| [ relation[a.first], a.last ] }
          im    = relation.create_insert

          im.into(relation)
          im.insert(binds)

          connection.insert(im, 'SQL')
        end

        def delete(conditions)
          relation_to_delete = nil
          conditions.each do |key, value|
            relation_to_delete = relation.where(relation[key].eq(value))
          end
          relation_to_delete.delete
        end

        private

        def read
          engine.adapter.execute(to_sql)
        end

        def to_sql
          # FIXME: we need introduce a common interface for aliases and columns header
          fields =
            if header.respond_to?(:columns)
              header.map(&:name)
            else
              # FIXME: this is obviously broken and only works with 1:1 and 1:m
              header.map do |name, field|
                "#{field.to_s.split('_').first}.#{name} AS #{field}"
              end
            end.join(', ')

          relation.project(fields).to_sql
        end

        def connection
          relation.engine.connection
        end

      end # class Gateway

    end # class ArelEngine
  end # class Engine
end # module DataMapper
