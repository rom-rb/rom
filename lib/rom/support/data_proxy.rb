module ROM
  module DataProxy
    NON_FORWARDABLE = [
      :each, :to_a, :to_ary, :kind_of?, :instance_of?, :is_a?
    ].freeze

    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        include Equalizer.new(:data)

        attr_reader :data, :header, :tuple_proc

        def initialize(data, header, tuple_proc = self.class.tuple_proc)
          @data = data
          @header = header
          @tuple_proc = tuple_proc
        end
      end
    end

    def each
      return to_enum unless block_given?
      data.each { |tuple| yield(tuple_proc[tuple]) }
    end

    module ClassMethods
      def tuple_proc
        -> tuple { tuple }
      end

      def forward(*methods)
        (Array(methods).flatten - NON_FORWARDABLE).each do |method_name|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method_name}(*args, &block)
              response = data.public_send(#{method_name.inspect}, *args, &block)

              if response.equal?(data)
                self
              elsif response.is_a?(data.class)
                self.class.new(response, header, tuple_proc)
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
