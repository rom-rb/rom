require 'spec_helper'
require 'rom/memory'

describe 'Repository' do
  let!(:setup) { ROM.setup(:memory) }

  let(:rom) { setup.finalize }

  before do
    module ROM
      module Memory
        module Relation
          def self.included(klass)
            klass.class_eval do
              def self.freaking_awesome?
                true
              end
            end
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
        Class.new(ROM::Relation[:memory]) { base_name :users }
      end
    end
  end
end
