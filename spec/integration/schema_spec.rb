require 'spec_helper'

describe 'Defining schema' do
  let(:setup) { ROM.setup(memory: 'memory://localhost') }
  let(:rom) { setup.finalize }
  let(:schema) { rom.schema }

  shared_context 'valid schema' do
    before do
      setup.schema do
        base_relation(:users) do
          repository :memory
        end
      end
    end

    it 'returns schema with relations' do
      users = schema.users

      expect(users.to_a).to eql(rom.memory.users.to_a)
    end
  end

  describe '.schema' do
    it 'returns an empty schema if it was not defined' do
      expect { schema.users }.to raise_error(NoMethodError)
    end

    context 'can be called multiple times' do
      before do
        setup.schema do
          base_relation(:tasks) do
            repository :memory
          end
        end

        setup.schema do
          base_relation(:tags) do
            repository :memory
          end
        end
      end

      it_behaves_like 'valid schema' do
        it 'registers all base relations' do
          expect(schema.tasks).to be(rom.memory.tasks)
          expect(schema.tags).to be(rom.memory.tags)
        end
      end
    end
  end
end
