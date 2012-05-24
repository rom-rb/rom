module Session
  # Adds autocommit support when included into Session
  module Autocommit
    # Persist domain object and commit this session
    #
    # @param [Object] object the object to be updated
    #
    def persist_now(object)
      assert_committed
      persist(object)
      commit
      
      self
    end

    # Update domain object and commit this session
    #
    # @param [Object] object the object to be updated
    #
    def update_now(object)
      assert_committed
      update(object)
      commit
      
      self
    end

    # Delete domain object and commit this session
    #
    # @param [Object] object the object to be deleted
    #
    def delete_now(object)
      assert_committed
      delete(object)
      commit
      
      self
    end

    # Insert domain object and commit this session
    #
    # @param [Object] object the object to be inserted
    #
    def insert_now(object)
      assert_committed
      insert(object)
      commit
      
      self
    end

  protected

    # Raise exception if session is NOT committed
    def assert_committed
      unless committed?
        raise 'session is not comitted'
      end

      self
    end
  end
end
