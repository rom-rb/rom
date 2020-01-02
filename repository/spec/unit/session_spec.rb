# frozen_string_literal: true

RSpec.describe ROM::Session do
  subject(:session) do
    ROM::Session.new(repo)
  end

  let(:repo) { instance_double(ROM::Repository) }
  let(:create_changeset) { instance_double(ROM::Changeset::Create, relation: relation) }
  let(:delete_changeset) { instance_double(ROM::Changeset::Delete, relation: relation) }
  let(:relation) { double.as_null_object }

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
      expect(create_changeset).to receive(:commit).and_return(true)

      session.add(create_changeset).commit!
      session.commit!

      expect(session).to be_success
    end

    it 'executes ops and restores pristine state when exception was raised' do
      expect(create_changeset).to_not receive(:commit)
      expect(delete_changeset).to receive(:commit).and_raise(StandardError, 'oops')

      expect {
        session.add(delete_changeset)
        session.add(create_changeset)
        session.commit!
      }.to raise_error(StandardError, 'oops')

      expect(session).to be_failure

      session.commit!
    end
  end
end
