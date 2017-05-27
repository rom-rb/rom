RSpec.describe ROM::Repository, '#inspect' do
  subject(:repo) do
    Class.new(ROM::Repository) do
      relations :users

      def self.to_s
        'UserRepo'
      end
    end.new(rom)
  end

  include_context 'database'
  include_context 'relations'

  specify do
    expect(repo.inspect).to eql('#<UserRepo relations=[:users]>')
  end
end
