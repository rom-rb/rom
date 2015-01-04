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
          method_names =
            if methods.size == 1 && methods.first.is_a?(Module)
              methods.first.public_instance_methods
            else
              methods
            end

          (method_names - [:each, :to_a, :to_ary]).each do |method_name|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{method_name}(*args, &block)
                self.class.new(
                  data.public_send(#{method_name.inspect}, *args, &block),
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
