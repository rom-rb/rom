module DataMapper
  class Engine
    module Arel

      class Gateway
        include Enumerable

        attr_reader :name

        attr_reader :header

        attr_reader :relation

        def initialize(relation, name = nil, header = nil)
          @relation = relation
          @name     = relation.respond_to?(:name)    ? relation.name    : name
          @header   = relation.respond_to?(:columns) ? relation.columns : header
        end

        def each(&block)
          return to_enum unless block_given?
          read.each(&block)
          self
        end

        def new(relation, header = @header)
          self.class.new(relation, name, header)
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
          connection.execute(to_sql)
        end

        def to_sql
          relation.project(header.map(&:name).join(', ')).to_sql
        end

        def connection
          relation.engine.connection
        end

      end # class Gateway

    end # module Arel
  end # class Engine
end # module DataMapper
