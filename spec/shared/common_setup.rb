RSpec.shared_context 'common setup' do
  let(:container) { ROM.create_container(configuration) }
  let!(:configuration) { ROM::Configuration.new(:memory).use(:macros) }

  let(:users_relation) {
    configuration
    configuration.register_relation(Class.new(ROM::Relation[:memory]) do
      register_as :users
      dataset :users
    end)
  }
end