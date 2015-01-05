require 'rom/data_proxy'

module ROM
  class EnumerableDataset
    include DataProxy

    forward(Enumerable.public_instance_methods)
  end
end
