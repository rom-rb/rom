RSpec.describe ROM::Session do
  subject(:session) do
    ROM::Session.new(repo)
  end

  let(:repo) { instance_double(ROM::Repository) }
  let(:changeset) { instance_double(ROM::Changeset::Create, relation: relation) }
  let(:relation) { double.as_null_object }
  let(:create_command) { spy(:create_command) }
  let(:delete_command) { spy(:delete_command) }

  describe '#commit!' do
    it 'executes ops and restores pristine state' do
      expect(repo).to receive(:command).with(:create, relation, mapper: false).and_return(create_command)

      session.create(changeset).commit!
      session.commit!

      expect(create_command).to have_received(:call)
    end

    it 'executes ops and restores pristine state when exception was raised' do
      expect(repo).to receive(:command).with(:delete, relation, mapper: false).and_return(delete_command)
      expect(repo).to receive(:command).with(:create, relation, mapper: false).and_return(create_command)

      expect(delete_command).to receive(:call).and_raise(StandardError, 'oops')

      expect { session.delete(relation).create(changeset).commit! }.to raise_error(StandardError, 'oops')

      session.commit!

      expect(create_command).not_to have_received(:call)
    end
  end
end
