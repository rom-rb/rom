# frozen_string_literal: true

require 'spec_helper'
require 'rom/memory'

RSpec.describe 'Gateways / Extending Relations' do
  include_context 'container'
  include_context 'users and tasks'

  before do
    module ROM
      module Memory
        class Relation < ROM::Relation
          schema(:users) {}

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

  after do
    ROM::Memory::Relation.class_eval do
      undef_method :freaking_cool?
      class << self
        undef_method :freaking_awesome?
      end
    end
  end

  shared_examples_for 'extended relation' do
    it 'can extend relation class' do
      expect(container.relations.users.class).to be_freaking_awesome
    end

    it 'can extend relation instance' do
      expect(container.relations.users).to be_freaking_cool
    end
  end

  context 'using DSL' do
    it_behaves_like 'extended relation' do
      before do
        configuration.relation(:users)
      end
    end
  end

  context 'using class definition' do
    it_behaves_like 'extended relation' do
      before do
        configuration.register_relation(Class.new(ROM::Relation[:memory]) { schema(:users) {} })
      end
    end
  end
end
