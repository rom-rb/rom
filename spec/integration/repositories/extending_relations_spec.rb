require 'spec_helper'
require 'rom/memory'

describe 'Repository' do
  let!(:setup) { ROM.setup(:memory) }

  let(:rom) { setup.finalize }

  before do
    module ROM
      module Memory
        class Relation < ROM::Relation
          def self.freaking_awesome?
            true
          end

          def freaking_cool?
            true
          end
        end
      end
    end
  end

  shared_examples_for 'extended relation' do
    it 'can extend relation class' do
      expect(rom.relations.users.class).to be_freaking_awesome
    end

    it 'can extend relation instance' do
      expect(rom.relations.users).to be_freaking_cool
    end
  end

  context 'using DSL' do
    it_behaves_like 'extended relation' do
      before do
        setup.relation(:users)
      end
    end
  end

  context 'using class definition' do
    it_behaves_like 'extended relation' do
      before do
        klass = Class.new(ROM::Relation[:memory]) { base_name :users }
        setup.register_relation(klass)
      end
    end
  end
end
