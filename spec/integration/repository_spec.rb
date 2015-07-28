RSpec.describe 'ROM repository' do
  include_context 'database'

  subject(:repo) { repo_class.new(rom) }

  let(:repo_class) do
    Class.new(ROM::Repository::Base) do
      relations :users

      def all
        users.select(:id, :name).order(:name, :id)
      end
    end
  end

  let(:struct) { repo.mapper_builder.struct_builder[users] }

  let(:users) { rom.relations[:users] }

  let(:jane) { struct.new(id: 1, name: 'Jane') }
  let(:joe) { struct.new(id: 2, name: 'Joe') }

  it 'loads a single relation' do
    conn[:users].insert name: 'Jane'
    conn[:users].insert name: 'Joe'

    expect(repo.all.to_a).to eql([jane, joe])
  end
end
