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

          attribute :id
          attribute :name
        end
      end
    end

    it 'returns schema with relations' do
      users = schema.users

      expect(rom.relations.users.header).to eql([:id, :name])
      expect(users.to_a).to eql(rom.memory.users.to_a)
    end
  end

  describe '.schema' do
    it 'returns an empty schema if it was not defined' do
      expect { schema.users }.to raise_error(NoMethodError)
    end

    context 'with an adapter that supports header injection' do
      it_behaves_like 'valid schema'
    end

    context 'can be called multiple times' do
      before do
        setup.schema do
          base_relation(:tasks) do
            repository :memory
            attribute :title
          end
        end

        setup.schema do
          base_relation(:tags) do
            repository :memory
            attribute :name
          end
        end
      end

      it_behaves_like 'valid schema' do
        it 'registers all base relations' do
          expect(schema.tasks).to be(rom.memory.tasks)
          expect(rom.relations.tasks.header).to eql([:title])

          expect(schema.tags).to be(rom.memory.tags)
          expect(rom.relations.tags.header).to eql([:name])
        end
      end
    end
  end
end
