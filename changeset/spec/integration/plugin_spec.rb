# frozen_string_literal: true

RSpec.describe 'changeset plugin' do
  subject(:changeset) do
    books.changeset(changeset_class).data(title: 'Hello World')
  end

  let(:changeset_class) do
    Class.new(ROM::Changeset::Create) do
      use :auto_touch
    end
  end

  include_context 'database'
  include_context 'relations'

  before do
    module Test
      module AutoTouch
        def self.apply(target, **)
          target.map { add_timestamps }
        end
      end
    end

    ROM.plugins do
      register :auto_touch, Test::AutoTouch, type: :changeset
    end
  end

  it 'extends changeset with the functionality provided by the plugin' do
    book = changeset.commit

    expect(book.created_at).to be_within(0.25).of(Time.now)
    expect(book.updated_at).to be_within(0.25).of(Time.now)
  end
end
