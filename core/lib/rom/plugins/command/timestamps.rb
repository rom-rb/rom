require 'set'

module ROM
  module Plugins
    module Command
      # A plugin for automatically adding timestamp values
      # when executing a command
      #
      # Set up attributes to timestamp when the command is called
      #
      # @example
      #   class CreateTask < ROM::Commands::Create[:sql]
      #     result :one
      #     use :timestamps, timestamps: %i(created_at, updated_at), datestamps: %i(:written)
      #   end
      #
      #   create_user = rom.command(:user).create.curry(name: 'Jane')
      #
      #   result = create_user.call
      #   result[:created_at]  #=> Time.now.utc
      #
      # @api public
      class Timestamps < Module
        attr_reader :timestamps, :datestamps
        def initialize(timestamps: [], datestamps: [])
          @timestamps = store_attributes(timestamps)
          @datestamps = store_attributes(datestamps)
        end

        # @api private
        def store_attributes(attr)
          attr.is_a?(Array) ? attr : Array[attr]
        end

        # @api private
        def included(klass)
          initialize_timestamp_attributes(klass)
          klass.include(InstanceMethods)
          klass.extend(ClassInterface)
          super
        end

        def initialize_timestamp_attributes(klass)
          klass.defines :timestamp_columns, :datestamp_columns
          klass.timestamp_columns Set.new
          klass.datestamp_columns Set.new
          klass.before :set_timestamps
          klass.timestamp_columns klass.timestamp_columns.merge(timestamps) if timestamps.any?
          klass.datestamp_columns klass.datestamp_columns.merge(datestamps) if datestamps.any?
        end

        module InstanceMethods
          # @api private
          def timestamp_columns
            self.class.timestamp_columns
          end

          # @api private
          def datestamp_columns
            self.class.datestamp_columns
          end

          # Set the timestamp attributes on the given tuples
          #
          # @param [Array<Hash>, Hash] tuples the input tuple(s)
          #
          # @return [Array<Hash>, Hash]
          #
          # @api private
          def set_timestamps(tuples, *)
            timestamps = build_timestamps

            map_input_tuples(tuples) { |t| timestamps.merge(t) }
          end

          private

          # @api private
          def build_timestamps
            time        = Time.now.utc
            date        = Date.today
            timestamps  = {}

            timestamp_columns.each do |column|
              timestamps[column.to_sym] = time
            end

            datestamp_columns.each do |column|
              timestamps[column.to_sym] = date
            end

            timestamps
          end
        end

        module ClassInterface
          # @api private
          # Set up attributes to timestamp when the command is called
          #
          # @example
          #   class CreateTask < ROM::Commands::Create[:sql]
          #     result :one
          #     use :timestamps
          #     timestamps :created_at, :updated_at
          #   end
          #
          #   create_user = rom.command(:user).create.curry(name: 'Jane')
          #
          #   result = create_user.call
          #   result[:created_at]  #=> Time.now.utc
          #
          # @param [Array<Symbol>] names A list of attribute names
          #
          # @api public
          def timestamps(*names)
            timestamp_columns timestamp_columns.merge(names)
          end
          alias timestamp timestamps

          # Set up attributes to datestamp when the command is called
          #
          # @example
          #   class CreateTask < ROM::Commands::Create[:sql]
          #     result :one
          #     use :timestamps
          #     datestamps :created_on, :updated_on
          #   end
          #
          #   create_user = rom.command(:user).create.curry(name: 'Jane')
          #
          #   result = create_user.call
          #   result[:created_at]  #=> Date.today
          #
          # @param [Array<Symbol>] names A list of attribute names
          #
          # @api public
          def datestamps(*names)
            datestamp_columns datestamp_columns.merge(names)
          end
          alias datestamp datestamps
        end
      end
    end
  end
end
