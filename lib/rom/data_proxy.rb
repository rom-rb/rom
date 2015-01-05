module ROM
  module DataProxy
    attr_reader :data, :header, :tuple_proc

    NON_FORWARDABLE = [
      :each, :to_a, :to_ary, :kind_of?, :instance_of?, :is_a?
    ].freeze

    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        include Equalizer.new(:data)
      end
    end

    def initialize(data, header)
      @data =
        if tuple_proc
          data.map { |tuple| tuple_proc[tuple] }
        else
          data
        end

      @header = header
    end

    def each(&block)
      return to_enum unless block_given?
      data.each(&block)
    end

    def to_a
      data.dup
    end
    alias_method :to_ary, :to_a

    module ClassMethods
      def forward(*methods)
        (Array(methods).flatten - NON_FORWARDABLE).each do |method_name|
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
