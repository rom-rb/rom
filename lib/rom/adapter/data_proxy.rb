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
        def forward(methods)
          (Array(methods) - [:each, :to_ary, :to_a]).each do |method_name|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{method_name}(*args, &block)
                response = data.public_send(#{method_name.inspect}, *args, &block)

                if response.is_a?(data.class)
                  self.class.new(response, header)
                else
                  response
                end
              end
            RUBY
          end
        end
      end
    end
  end
end
