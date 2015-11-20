module ROM
  class AutoRegistration
    def initialize(directory, options = {})
      @directory = directory
      @namespace = options.fetch(:namespace, Object)
      @entities = Hash[[:relations, :commands, :mappers].map { |e|
        opts = {
          directory: File.join(@directory, "#{e}"),
          namespace: @namespace
        }.merge(options.fetch(e, {}))

        [e, opts]
      }]
    end

    def relations
      load_entities(:relations)
    end

    def commands
      load_entities(:commands)
    end

    def mappers
      load_entities(:mappers)
    end

    private

    def load_entities(entity)
      files = Dir[files_for(entity)]
      files.map do |f|
        require f

        Object.const_get(constant_name_for(entity, f))
      end
    end

    def constant_name_for(entity, filename)
      [@entities[entity][:namespace], constant_name(filename).to_sym].join("::")
    end

    def constant_name(filename)
      File.basename(filename, ".rb").split(/_/).map(&:capitalize).join()
    end

    def namespace_for(entity)
      Object.const_get()
    end

    def files_for(entity)
      File.join(directory_for(entity), "*.rb")
    end

    def directory_for(entity)
      @entities[entity][:directory]
    end
  end
end