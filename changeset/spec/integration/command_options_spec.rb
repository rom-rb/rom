# frozen_string_literal: true

RSpec.describe 'changeset plugin' do
  subject(:changeset) do
    books.changeset(changeset_class).data(title: 'Hello World')
  end

  let(:changeset_class) do
    Class.new(ROM::Changeset::Create) do
      command_options input: -> tuple { tuple.merge(updated_at: Time.now) }
      command_plugins timestamps: { timestamps: [:created_at] }
    end
  end

  include_context 'database'
  include_context 'relations'

  it 'extends the command with the provided command options' do
    book = changeset.commit

    expect(book.created_at).to be_within(0.25).of(Time.now)
    expect(book.updated_at).to be_within(0.25).of(Time.now)
  end
end
