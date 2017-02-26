require 'spec_helper'

RSpec.describe ROM::Changeset, '#associate' do
  include_context 'database'
  include_context 'relations'

  let(:user_repo) do
    Class.new(ROM::Repository[:users]) { commands :create }.new(rom)
  end

  let(:task_repo) do
    Class.new(ROM::Repository[:tasks]) { commands :create }.new(rom)
  end

  context 'with Create' do
    let!(:jane) do
      user_repo.create(name: 'Jane')
    end

    it 'associates child with parent' do
      changeset = task_repo.changeset(title: 'Test 1')

      expect(changeset.associate(jane, :user).commit).
        to include(user_id: jane.id, title: 'Test 1')
    end
  end

  context 'with Update' do
    let!(:john) do
      user_repo.create(name: 'John')
    end

    let!(:jane) do
      user_repo.create(name: 'Jane')
    end

    let!(:task) do
      task_repo.create(title: 'Test 1', user_id: john.id)
    end

    it 'associates child with parent' do
      changeset = task_repo.changeset(task.id, title: 'Test 2')

      expect(changeset.associate(jane, :user).commit).
        to include(user_id: jane.id, title: 'Test 2')
    end
  end
end
