require 'spec_helper'

describe ROM::Repository do
  include_context 'users and tasks'

  subject(:repository) { rom.repositories[:default] }

  before { setup.relation(:users) }

  it 'exposes datasets on method-missing' do
    expect(repository.users).to be(rom.repositories[:default][:users])
  end

  it 'responds to methods corresponding to dataset names' do
    expect(repository).to respond_to(:users)
  end

  it 'raises exception when unknown dataset is referenced' do
    expect { repository.not_here }.to raise_error(NoMethodError)
  end
end
