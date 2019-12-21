RSpec.shared_context 'plugins' do
  before do
    module Test
      class WrappingInput
        def initialize(input)
          @input = input || Hash
        end
      end

      module Timestamps
        class InputWithTimestamp < WrappingInput
          def [](value)
            v = @input[value]
            now = Time.now

            if v[:created_at]
              v.merge(updated_at: now)
            else
              v.merge(created_at: now, updated_at: now)
            end
          end
        end

        module ClassInterface
          def build(relation, **options)
            super(relation, **options, input: InputWithTimestamp.new(input))
          end
        end

        def self.included(klass)
          super

          klass.extend ClassInterface
        end
      end

      module UpcaseName
        class UpcaseNameInput < WrappingInput
          def [](value)
            v = @input[value]
            v.merge(name: value.fetch(:name).upcase)
          end
        end

        module ClassInterface
          def build(relation, **options)
            super(relation, **options, input: UpcaseNameInput.new(options.fetch(:input)))
          end
        end

        def self.included(klass)
          super

          klass.extend ClassInterface
        end
      end

      class ModifyName < ::Module
        attr_reader :opts

        def initialize(opts = {})
          @opts = opts
        end

        def included(klass)
          super
          klass.defines :reverse
          klass.reverse opts[:reverse]
          klass.before :modify_name
          klass.include InstanceInterface
        end

        module InstanceInterface

          def reverse?
            self.class.reverse
          end

          def modify_name(tuples, *)
            if reverse?
              tuples.merge(name: tuples[:name].reverse)
            else
              tuples
            end
          end
        end
      end
    end

    ROM.plugins do
      adapter :sql do
        register :timestamps, Test::Timestamps, type: :command
        register :upcase_name, Test::UpcaseName, type: :command
        register :modify_name, Test::ModifyName, type: :command
      end
    end
  end
end
