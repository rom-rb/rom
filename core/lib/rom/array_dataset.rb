# frozen_string_literal: true

require 'rom/initializer'
require 'rom/enumerable_dataset'

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
        extend Initializer
        include DataProxy

        param :data
      end
    end

    forward(
      :*, :+, :-, :compact, :compact!, :flatten, :flatten!, :length, :pop,
      :reverse, :reverse!, :sample, :size, :shift, :shuffle, :shuffle!,
      :slice, :slice!, :sort!, :uniq, :uniq!, :unshift, :values_at
    )

    %i[
      map! combination cycle delete_if keep_if permutation reject!
      select! sort_by!
    ].each do |method|
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{method}(*args, &)                                          # def map!(*args, &)
          return to_enum unless block_given?                             #   return to_enum unless block_given?
          self.class.new(data.__send__(:#{method}, *args, &), **options) #   self.class.new(data.__send__(:map!, *args, &), **options)
        end                                                              # end
      RUBY
    end
  end
end
