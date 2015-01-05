require 'rom/data_proxy'

module ROM
  class EnumerableDataset
    include DataProxy
    include Enumerable

    def find_all(&block)
      self.class.new(super(&block), header)
    end

    def sort_by(&block)
      self.class.new(super(&block), header)
    end

    # FIXME: why is this needed for rubinius?
    def sort!(*args, &block)
      data.sort!(*args, &block)
    end
  end
end
