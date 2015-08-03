RSpec.describe 'ROM repository' do
  include_context 'database'
  include_context 'relations'
  include_context 'seeds'
  include_context 'structs'

  it 'loads a single relation' do
    expect(repo.all_users.to_a).to eql([jane, joe])
  end

  it 'loads a combined relation with many children' do
    expect(repo.users_with_tasks.to_a).to eql([jane_with_tasks, joe_with_tasks])
  end

  it 'loads a combined relation with one child' do
    expect(repo.users_with_task.to_a).to eql([jane_with_task, joe_with_task])
  end

  it 'loads a combined relation with one child restricted by given criteria' do
    expect(repo.users_with_task_by_title('Joe Task').to_a).to eql([
      jane_without_task, joe_with_task
    ])
  end

  it 'loads a combined relation with one parent' do
    expect(repo.users_with_task.first).to eql(jane_with_task)
  end

  it 'loads nested combined relations' do
    expect(repo.users_with_tasks_and_tags.first).to eql(user_with_task_and_tags)
  end

  it 'loads a wrapped relation' do
    expect(repo.tag_with_wrapped_task.first).to eql(tag_with_task)
  end
end
