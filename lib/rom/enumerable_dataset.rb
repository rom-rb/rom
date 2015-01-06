require 'rom/support/data_proxy'

module ROM
  module EnumerableDataset
    include Enumerable

    alias_method :to_ary, :to_a

    def self.included(klass)
      return unless klass.is_a?(Class)
      klass.send(:include, DataProxy)
    end

    [
      :chunk, :collect, :collect_concat, :drop_while, :find_all, :flat_map,
      :grep, :map, :reject, :select, :sort, :sort_by, :take_while
    ].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args, &block)
          return to_enum unless block
          self.class.new(super(*args, &block), header, tuple_proc)
        end
      RUBY
    end
  end
end
