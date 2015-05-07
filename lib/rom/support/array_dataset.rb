require 'rom/support/enumerable_dataset'

module ROM
  # A helper module that adds data-proxy behavior to an array-like object
  #
  # @see EnumerableDataset
  #
  # @api public
  module ArrayDataset
    extend DataProxy::ClassMethods
    include EnumerableDataset

    # Extends the class with data-proxy behavior
    #
    # @api private
    def self.included(klass)
      klass.class_eval do
        include Options
        include DataProxy
      end
    end

    forward(
      :*, :+, :-, :compact, :compact!, :flatten, :flatten!, :length, :pop,
      :reverse, :reverse!, :sample, :size, :shift, :shuffle, :shuffle!,
      :slice, :slice!, :sort!, :uniq, :uniq!, :unshift, :values_at
    )

    [
      :map!, :combination, :cycle, :delete_if, :keep_if, :permutation, :reject!,
      :select!, :sort_by!
    ].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args, &block)
          return to_enum unless block
          self.class.new(data.send(:#{method}, *args, &block), options)
        end
      RUBY
    end
  end
end
