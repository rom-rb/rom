require 'rom/enumerable_dataset'

module ROM
  class ArrayDataset < EnumerableDataset
    forward(:last, :size, :map, :map!, :flatten)
  end
end
