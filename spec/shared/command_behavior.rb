# frozen_string_literal: true

shared_examples_for 'a command' do
  describe '#name' do
    it 'returns relation name' do
      expect(command.name).to eql(command.relation.name)
    end
  end

  describe '#gateway' do
    it 'returns relation gateway' do
      expect(command.gateway).to eql(command.relation.gateway)
    end
  end

  describe '#method_missing' do
    it 'forwards to relation and wraps response if it returned another relation' do
      if command.class.restrictable
        new_command = command.by_id(1)

        expect(new_command).to be_instance_of(command.class)
        expect(new_command.relation).to eql(command.by_id(1).relation)
      end
    end

    it 'raises error when message is not known' do
      expect { command.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
