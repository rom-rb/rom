# frozen_string_literal: true

require 'rom/relation'

RSpec.describe ROM::Relation, '#command' do
  subject(:relation) do
    ROM::Relation.new([], name: ROM::Relation::Name[:users], commands: commands, auto_map: false)
  end

  let(:commands) do
    {}
  end

  context 'when command is already registered' do
    before do
      commands[:my_command] = custom_command
    end

    context 'when command is not restrictible' do
      let(:custom_command) do
        double(:command, restrictible?: false)
      end

      it 'returns the command if it exists in the registry already' do
        expect(relation.command(:my_command)).to be(custom_command)
      end
    end

    context 'when command is restrictible' do
      let(:custom_command) do
        double(:command, restrictible?: true)
      end

      it 'returns the command if it exists in the registry already' do
        expect(custom_command).to receive(:new).with(relation).and_return(custom_command)

        expect(relation.command(:my_command)).to be(custom_command)
      end
    end
  end
end
