RSpec.describe ROM::Session do
  subject(:session) do
    ROM::Session.new(repo)
  end

  let(:repo) { instance_double(ROM::Repository) }
  let(:create_changeset) { instance_double(ROM::Changeset::Create, relation: relation) }
  let(:delete_changeset) { instance_double(ROM::Changeset::Delete, relation: relation) }
  let(:relation) { double.as_null_object }
  let(:create_command) { spy(:create_command) }
  let(:delete_command) { spy(:delete_command) }

  describe '#pending?' do
    it 'returns true before commit' do
      expect(session).to be_pending
    end

    it 'returns false after commit' do
      expect(session.commit!).to_not be_pending
    end
  end

  describe '#commit!' do
    it 'executes ops and restores pristine state' do
      expect(create_changeset).to receive(:command).and_return(create_command)

      session.add(create_changeset).commit!
      session.commit!

      expect(session).to be_success

      expect(create_command).to have_received(:call)
    end

    it 'executes ops and restores pristine state when exception was raised' do
      expect(create_changeset).to receive(:command).and_return(create_command)
      expect(delete_changeset).to receive(:command).and_return(delete_command)

      expect(delete_command).to receive(:call).and_raise(StandardError, 'oops')

      expect {
        session.add(delete_changeset)
        session.add(create_changeset)
        session.commit!
      }.to raise_error(StandardError, 'oops')

      expect(session).to be_failure

      session.commit!

      expect(create_command).not_to have_received(:call)
    end
  end
end
