RSpec.describe 'ROM repository with typed structs' do
  subject(:repo) do
    Class.new(ROM::Repository[:books]).new(rom)
  end

  include_context 'database'
  include_context 'seeds'

  before do
    configuration.relation(:books) do
      schema(infer: true)

      view(:index) do
        schema { project(:id, :title, :created_at) }
        relation { order(:title) }
      end
    end

    rom.relations[:books].insert(title: 'Hello World', created_at: Time.now)
  end

  it 'loads typed structs' do
    book = repo.books.index.first

    expect(book).to be_kind_of(Dry::Struct)

    expect(book.id).to be_kind_of(Integer)
    expect(book.title).to eql('Hello World')
    expect(book.created_at).to be_kind_of(Time)
  end
end
