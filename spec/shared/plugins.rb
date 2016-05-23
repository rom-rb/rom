RSpec.shared_context 'plugins' do
  before do
    module Test
      module Timestamps
        class InputWithTimestamp
          def [](value)
            now = Time.now

            if value[:created_at]
              value.to_h.merge(updated_at: now)
            else
              value.to_h.merge(created_at: now, updated_at: now)
            end
          end
        end

        module ClassInterface
          def build(relation, options = {})
            super(relation, options.merge(input: InputWithTimestamp.new))
          end
        end

        def self.included(klass)
          super

          klass.extend ClassInterface
        end
      end
    end

    ROM.plugins do
      adapter :sql do
        register :timestamps, Test::Timestamps, type: :command
      end
    end
  end
end
