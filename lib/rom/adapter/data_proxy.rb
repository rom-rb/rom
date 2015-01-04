module ROM
  class Adapter
    module DataProxy
      attr_reader :data, :header, :tuple_proc

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      def initialize(data, header)
        @data = data
        @header = header
        @tuple_proc = -> tuple { tuple }
      end

      def each
        return to_enum unless block_given?
        data.each { |tuple| yield(tuple_proc[tuple]) }
      end

      def to_ary
        data.dup
      end
      alias_method :to_a, :to_ary

      module ClassMethods
        def forward(*methods)
          methods.each do |name|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{name}(*args, &block)
                self.class.new(
                  data.public_send(#{name.inspect}, *args, &block),
                  header
                )
              end
            RUBY
          end
        end
      end
    end
  end
end
