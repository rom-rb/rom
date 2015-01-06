require 'rom/enumerable_dataset'

module ROM
  # A helper module that adds data-proxy behavior to an array-like object
  #
  # @see EnumerableDataset
  #
  # @public
  module ArrayDataset
    extend DataProxy::ClassMethods
    include EnumerableDataset

    # Extends the class with data-proxy behavior
    #
    # @api private
    def self.included(klass)
      klass.send(:include, DataProxy)
    end

    forward(
      :*, :+, :-, :compact, :compact!, :delete_if, :flatten, :flatten!, :keep_if,
      :map!, :length, :pop, :reject, :reject!, :reverse, :reverse!, :sample,
      :select!, :size, :shift, :shuffle, :shuffle!, :slice, :slice!, :sort!,
      :sort_by!, :uniq, :uniq!, :unshift, :values_at
    )
  end
end
