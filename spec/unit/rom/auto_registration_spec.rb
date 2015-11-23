require 'spec_helper'
require 'rom/setup/auto_registration'

RSpec.describe ROM::Setup, '#auto_registration' do
  let(:setup) { ROM::Setup.new }

  context 'with namespace turned on' do
    before do
      setup.auto_registration(SPEC_ROOT.join('fixtures/lib/persistence'))
    end

    describe '#relations' do
      it 'loads files and returns constants' do
        expect(setup.relation_classes).to eql([Persistence::Relations::Users])
      end
    end

    describe '#commands' do
      it 'loads files and returns constants' do
        expect(setup.command_classes).to eql([Persistence::Commands::CreateUser])
      end
    end

    describe '#mappers' do
      it 'loads files and returns constants' do
        expect(setup.mapper_classes).to eql([Persistence::Mappers::UserList])
      end
    end
  end

  context 'with namespace turned off' do
    before do
      setup.auto_registration(SPEC_ROOT.join('fixtures/app'), namespace: false)
    end

    describe '#relations' do
      it 'loads files and returns constants' do
        expect(setup.relation_classes).to eql([Users])
      end
    end

    describe '#commands' do
      it 'loads files and returns constants' do
        expect(setup.command_classes).to eql([CreateUser])
      end
    end

    describe '#mappers' do
      it 'loads files and returns constants' do
        expect(setup.mapper_classes).to eql([UserList])
      end
    end
  end
end
