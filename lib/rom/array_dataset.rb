require 'rom/enumerable_dataset'

module ROM
  class ArrayDataset < EnumerableDataset
    forward(
      :*, :+, :-, :compact, :compact!, :delete_if, :flatten, :flatten!, :keep_if,
      :map!, :length, :pop, :reject, :reject!, :reverse, :reverse!, :sample,
      :select!, :size, :shift, :shuffle, :shuffle!, :slice, :slice!, :sort!,
      :sort_by!, :uniq, :uniq!, :unshift, :values_at
    )
  end
end
