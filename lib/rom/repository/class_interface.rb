module ROM
  class Repository
    module ClassInterface
      # Create a root-repository class and set its root relation
      #
      # @api public
      def [](name)
        klass = Class.new(self < Repository::Root ? self : Repository::Root)
        klass.relations(name)
        klass.root(name)
        klass
      end

      # @api private
      def inherited(klass)
        super

        return if self === Repository

        klass.relations(*relations)
        klass.commands(*commands)
      end

      # Define which relations your repository is going to use
      #
      # @example
      #   class MyRepo < ROM::Repository::Base
      #     relations :users, :tasks
      #   end
      #
      #   my_repo = MyRepo.new(rom_env)
      #
      #   my_repo.users
      #   my_repo.tasks
      #
      # @return [Array<Symbol>]
      #
      # @api public
      def relations(*names)
        if names.any?
          attr_reader(*names)

          if defined?(@relations)
            @relations.concat(names).uniq!
          else
            @relations = names
          end

          @relations
        else
          @relations
        end
      end

      # @api public
      def commands(*names, mapper: nil, use: nil, **opts)
        if names.any? || opts.any?
          @commands = names + opts.to_a

          @commands.each do |spec|
            type, *view = Array(spec).flatten

            if view.size > 0
              define_restricted_command_method(type, view, mapper: mapper, use: use)
            else
              define_command_method(type, mapper: mapper, use: use)
            end
          end
        else
          @commands || []
        end
      end

      # @api private
      def define_command_method(type, **opts)
        define_method(type) do |*args|
          command(type => self.class.root, **opts).call(*args)
        end
      end

      # @api private
      def define_restricted_command_method(type, views, **opts)
        views.each do |view_name|
          meth_name = views.size > 1 ? :"#{type}_#{view_name}" : type

          define_method(meth_name) do |*args|
            view_args, *input = args

            changeset = input.first

            if changeset.is_a?(Changeset) && changeset.clean?
              map_tuple(changeset.relation, changeset.original)
            else
              command(type => self.class.root, **opts)
                .public_send(view_name, *view_args)
                .call(*input)
            end
          end
        end
      end
    end
  end
end
