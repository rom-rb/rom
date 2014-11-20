require 'rom/ra/operation/join'
require 'rom/ra/operation/group'
require 'rom/ra/operation/wrap'

module ROM

  module RA

    def in_memory(&block)
      DSL.new(self).instance_exec(&block)
    end

    class DSL
      include Concord.new(:relation)

      def join(*args)
        left, right = args.size > 1 ? args : [relation, args.first]
        Operation::Join.new(left, right)
      end

      def group(*args)
        with_options(*args) { |relation, options|
          Operation::Group.new(relation, options)
        }
      end

      def wrap(*args)
        with_options(*args) { |relation, options|
          Operation::Wrap.new(relation, options)
        }
      end

      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      private

      def with_options(*args)
        relation =
          if args.size > 1
            args.first
          else
            self.relation
          end

        options = args.last

        yield(relation, options)
      end

      def method_missing(name, *args, &block)
        relation.public_send(name, *args, &block)
      end

    end

  end

end
