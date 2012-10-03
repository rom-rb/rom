module DataMapper

  # Mapper that intercepts operations and registres the to UoW
  class Interceptor
    include Immutable

    # Delegate boring mapper methods
    %w(load dump dump_key).each do |name|
      class_eval(<<-RUBY, __FILE__, __LINE__+1)
        def #{name}(*args)
          @mapper.#{name}(*args)
        end
      RUBY
    end

    # Return mapper
    #
    # @return [Mapper]
    #
    # @api private
    #
    attr_reader :mapper

    # Intercept delete command
    #
    # @param [Sttate] state
    #
    # @return [self]
    #
    # @api private
    #
    def delete(state)
      register(Command::Delete.new(state))
      self
    end

    # Intercept update command
    #
    # @param [State] new_state
    # @param [State] old_state
    #
    # @return [self]
    #
    # @api private
    #
    def update(new_state, old_state)
      register(Command::Update.new(new_state, old_state))
      self
    end

    # Intercept insert command
    #
    # @param [State] state
    #
    # @return [self]
    #
    # @api private
    #
    def insert(state)
      register(Command::Insert.new(state))
      self
    end

  private

    # Initialize object
    #
    # @param [Work] work
    # @param [Mapper] mapper
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(work, mapper)
      @work   = work
      @mapper = mapper
    end

    # Register command
    #
    # @param [Command]
    #
    # @return [undefined]
    #
    # @api private
    #
    def register(command)
      @work.register(command)
    end
  end
end
