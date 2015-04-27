require 'rom/support/data_proxy'

module ROM
  # A helper module that adds data-proxy behavior to an enumerable object
  #
  # This module is intended to be used by repositories
  #
  # Class that includes this module can define `row_proc` class method which
  # must return a proc-like object which will be used to process each element
  # in the enumerable
  #
  # @example
  #   class MyDataset
  #     include ROM::EnumerableDataset
  #
  #     def self.row_proc
  #       -> tuple { tuple.each_with_object({}) { |(k,v), h| h[k.to_sym] = v } }
  #     end
  #   end
  #
  #   ds = MyDataset.new([{ 'name' => 'Jane' }, [:name])
  #   ds.to_a # => { :name => 'Jane' }
  #
  # @api public
  module EnumerableDataset
    extend DataProxy::ClassMethods
    include Enumerable

    # Coerce a dataset to an array
    #
    # @return [Array]
    #
    # @api public
    alias_method :to_ary, :to_a

    # Included hook which extends a class with DataProxy behavior
    #
    # This module can also be included into other modules so we apply the
    # extension only for classes
    #
    # @api private
    def self.included(klass)
      return unless klass.is_a?(Class)

      klass.class_eval do
        include Options
        include DataProxy
      end
    end

    forward :take

    [
      :chunk, :collect, :collect_concat, :drop_while, :find_all, :flat_map,
      :grep, :map, :reject, :select, :sort, :sort_by, :take_while
    ].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args, &block)
          return to_enum unless block
          self.class.new(super(*args, &block), options)
        end
      RUBY
    end
  end
end
