# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class View < Core
      # @!attribute [r] relation_id
      #   @return [Symbol] Relation runtime identifier
      #   @api private
      option :relation_id

      # @!attribute [r] relation_block
      #   @return [Proc] Block used for view method definition
      #   @api private
      option :relation_block

      # @return [ROM::Relation]
      #
      # @api private
      def define(constant)
        _name = config.id
        _relation_block = relation_block

        if relation_block&.arity&.positive?
          constant.class_eval do
            auto_curry_guard do
              define_method(_name, &_relation_block)

              auto_curry(_name) do
                schemas[_name].(self)
              end
            end
          end
        else
          constant.class_eval do
            define_method(_name) do
              schemas[_name].(instance_eval(&_relation_block))
            end
          end
        end

        _name
      end
    end
  end
end
