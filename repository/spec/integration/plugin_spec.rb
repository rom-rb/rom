RSpec.describe 'repository plugin' do
  include_context 'database'
  include_context 'relations'
  include_context 'seeds'
  include_context 'repo'

  let(:nullify_plugin) do
    Module.new do
      def self.apply(target, _options)
        target.prepend(self)
      end

      def set_relation(*)
        super.where { `1 = 0` }
      end
    end
  end

  before do
    plugin = nullify_plugin

    ROM.plugins do
      register :nullify_datasets, plugin, type: :repository
    end
  end

  let(:user_repo) do
    Class.new(repo_class) { use :nullify_datasets }.new(rom)
  end

  it 'always returns empty result set' do
    expect(user_repo.all_users.to_a).to eql([])
  end
end
