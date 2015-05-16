module ROM
  # Data pipeline common interface
  #
  # @api public
  module Pipeline
    # Compose two relation with a left-to-right composition
    #
    # @example
    #   users.by_name('Jane') >> tasks.for_users
    #
    # @param [Relation] other The right relation
    #
    # @return [Relation::Composite]
    #
    # @api public
    def >>(other)
      Relation::Composite.new(self, other)
    end
  end
end
