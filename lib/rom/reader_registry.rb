require 'rom/reader_registry/dsl'

module ROM

  class ReaderRegistry
    attr_reader :readers

    def initialize(readers = {})
      @readers = readers
    end

    def self.define(relations, &block)
      dsl = DSL.new(relations)
      dsl.instance_exec(&block)
      dsl.call
    end

    def [](name)
      readers.fetch(name)
    end

    def respond_to_missing?(name, include_private = false)
      readers.key?(name)
    end

    private

    def method_missing(name)
      readers[name]
    end

  end

end
