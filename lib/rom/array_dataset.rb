require 'rom/enumerable_dataset'

module ROM
  module ArrayDataset
    extend DataProxy::ClassMethods
    include EnumerableDataset

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
