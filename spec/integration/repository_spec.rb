RSpec.describe 'ROM repository' do
  include_context 'database'

  subject(:user_repo) { repo_class.new(users) }

  let(:repo_class) do
    Class.new(ROM::Repository::Base) do
      def all
        load { relation.select(:id, :name).order(:name, :id) }
      end
    end
  end

  let(:model) { user_repo.model_for(users) }

  let(:users) { rom.relations[:users] }

  let(:jane) { model.new(id: 1, name: 'Jane') }
  let(:joe) { model.new(id: 2, name: 'Joe') }

  it 'works' do
    conn[:users].insert name: 'Jane'
    conn[:users].insert name: 'Joe'

    expect(user_repo.all).to eq([jane, joe])
  end
end
