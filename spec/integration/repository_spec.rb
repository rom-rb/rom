RSpec.describe 'ROM repository' do
  include_context 'database'
  include_context 'relations'
  include_context 'seeds'
  include_context 'structs'

  it 'loads a single relation' do
    expect(repo.all_users.to_a).to match_array([jane, joe])
  end

  it 'can be used with a custom mapper' do
    expect(repo.all_users_as_users.to_a).to match_array([
      Test::Models::User.new(jane),
      Test::Models::User.new(joe)
    ])
  end

  it 'loads a relation by an association' do
    expect(repo.tasks_for_users(repo.all_users)).to match_array([jane_task, joe_task])
  end

  it 'loads a combine relation with one parent' do
    task = repo.task_with_user.first

    expect(task.id).to eql(task_with_user.id)
    expect(task.title).to eql(task_with_user.title)
    expect(task.user.id).to eql(task_with_user.user.id)
    expect(task.user.name).to eql(task_with_user.user.name)
  end

  it 'loads a combine relation with one parent with custom tuple key' do
    expect(repo.task_with_owner.first).to eql(task_with_owner)
  end

  it 'loads a combined relation with many children' do
    expect(repo.users_with_tasks.to_a).to match_array([jane_with_tasks, joe_with_tasks])
  end

  it 'loads a combined relation with one child' do
    expect(repo.users_with_task.to_a).to match_array([jane_with_task, joe_with_task])
  end

  it 'loads a combined relation with one child restricted by given criteria' do
    expect(repo.users_with_task_by_title('Joe Task').to_a).to match_array([
      jane_without_task, joe_with_task
    ])
  end

  it 'loads nested combined relations' do
    user = repo.users_with_tasks_and_tags.first

    expect(user.id).to be(1)
    expect(user.name).to eql('Jane')
    expect(user.all_tasks.size).to be(1)
    expect(user.all_tasks[0].id).to be(2)
    expect(user.all_tasks[0].title).to eql('Jane Task')
    expect(user.all_tasks[0].tags.size).to be(1)
    expect(user.all_tasks[0].tags[0].name).to eql('red')
  end

  it 'loads nested combined relations using configured associations' do
    jane = repo.users_with_posts_and_their_labels.first

    expect(jane.posts.size).to be(1)
    expect(jane.posts.map(&:title)).to eql(['Hello From Jane'])
    expect(jane.posts.flat_map(&:labels).flat_map(&:name)).to eql(%w(red blue))
  end

  it 'loads a wrapped relation' do
    expect(repo.tag_with_wrapped_task.first).to eql(tag_with_task)
  end

  it 'loads multiple wraps' do
    post_label = repo.posts_labels.wrap(:post).wrap(:label).to_a.first

    expect(post_label.label_id).to be(post_label.label.id)
    expect(post_label.post_id).to be(post_label.post.id)
  end

  it 'loads an aggregate via custom fks' do
    jane = repo.aggregate(many: repo.posts).where(name: 'Jane').one

    expect(jane.posts.size).to be(1)
    expect(jane.posts.first.title).to eql('Hello From Jane')
  end

  it 'loads an aggregate via assoc name' do
    jane = repo.aggregate(:posts).where(name: 'Jane').one

    expect(jane.posts.size).to be(1)
    expect(jane.posts.first.title).to eql('Hello From Jane')
  end

  it 'loads an aggregate via assoc options' do
    jane = repo.aggregate(posts: :labels).where(name: 'Jane').one

    expect(jane.name).to eql('Jane')
    expect(jane.posts.size).to be(1)
    expect(jane.posts.first.title).to eql('Hello From Jane')
    expect(jane.posts[0].labels.size).to be(2)
    expect(jane.posts[0].labels[0].name).to eql('red')
    expect(jane.posts[0].labels[1].name).to eql('blue')
  end

  it 'loads an aggregate with multiple assoc options' do
    jane = repo.aggregate(:labels, posts: :labels).where(name: 'Jane').one

    expect(jane.name).to eql('Jane')

    expect(jane.labels.size).to be(2)
    expect(jane.labels[0].name).to eql('red')
    expect(jane.labels[1].name).to eql('blue')

    expect(jane.posts.size).to be(1)
    expect(jane.posts[0].title).to eql('Hello From Jane')

    expect(jane.posts[0].labels.size).to be(2)
    expect(jane.posts[0].labels[0].name).to eql('red')
    expect(jane.posts[0].labels[1].name).to eql('blue')
  end

  it 'loads an aggregate with deeply nested assoc options' do
    jane = repo.aggregate(posts: [{ author: :labels }]).where(name: 'Jane').one

    expect(jane.posts.size).to be(1)
    expect(jane.posts[0].title).to eql('Hello From Jane')

    expect(jane.posts[0].author.id).to eql(jane.id)
    expect(jane.posts[0].author.labels.size).to be(2)
    expect(jane.posts[0].author.labels[0].name).to eql('red')
    expect(jane.posts[0].author.labels[1].name).to eql('blue')
  end

  it 'loads an aggregate with multiple associations' do
    jane = repo.aggregate(:posts, :labels).where(name: 'Jane').one

    expect(jane.posts.size).to be(1)
    expect(jane.posts.first.title).to eql('Hello From Jane')

    expect(jane.labels.size).to be(2)
    expect(jane.labels[0].name).to eql('red')
    expect(jane.labels[1].name).to eql('blue')
  end

  it 'loads children and its parents via wrap_parent' do
    posts = repo.posts.wrap_parent(author: repo.users)

    label = repo.labels.combine(many: { posts: posts }).first

    expect(label.name).to eql('red')
    expect(label.posts.size).to be(1)
    expect(label.posts[0].title).to eql('Hello From Jane')
    expect(label.posts[0].author.name).to eql('Jane')
  end

  it 'loads children and its parents via wrap and association name' do
    label = repo.labels.combine(many: { posts: repo.posts.wrap(:author) }).first

    expect(label.name).to eql('red')
    expect(label.posts.size).to be(1)
    expect(label.posts[0].title).to eql('Hello From Jane')
    expect(label.posts[0].author.name).to eql('Jane')
  end

  it 'loads a parent via custom fks' do
    post = repo.posts.combine(:author).where(title: 'Hello From Jane').one

    expect(post.title).to eql('Hello From Jane')
    expect(post.author.name).to eql('Jane')
  end

  it 'loads aggregate through many-to-many via custom options' do
    post = repo.posts
      .combine_children(many: repo.labels)
      .where(title: 'Hello From Jane')
      .one

    expect(post.title).to eql('Hello From Jane')
    expect(post.labels.size).to be(2)
    expect(post.labels.map(&:name)).to eql(%w(red blue))
  end

  it 'loads aggregate through many-to-many association' do
    post = repo.posts.combine(:labels).where(title: 'Hello From Jane').one

    expect(post.title).to eql('Hello From Jane')
    expect(post.labels.size).to be(2)
    expect(post.labels.map(&:name)).to eql(%w(red blue))
  end

  it 'loads multiple child relations' do
    user = repo.users.combine_children(many: [repo.posts, repo.tasks]).where(name: 'Jane').one

    expect(user.name).to eql('Jane')
    expect(user.posts.size).to be(1)
    expect(user.posts[0].title).to eql('Hello From Jane')
    expect(user.tasks.size).to be(1)
    expect(user.tasks[0].title).to eql('Jane Task')
  end

  it 'loads multiple parent relations' do
    post_label = repo.posts_labels.combine_parents(one: [repo.posts]).first

    expect(post_label.post.title).to eql('Hello From Jane')
  end

  context 'not common naming conventions' do
    it 'still loads nested relations' do
      comments = comments_repo.comments_with_likes.to_a

      expect(comments.size).to be(2)
      expect(comments[0].author).to eql('Jane')
      expect(comments[0].likes[0].author).to eql('Joe')
      expect(comments[0].likes[1].author).to eql('Anonymous')
      expect(comments[1].author).to eql('Joe')
      expect(comments[1].likes[0].author).to eql('Jane')
    end

    it 'loads nested relations by association name' do
      comments = comments_repo.comments_with_emotions.to_a

      expect(comments.size).to be(2)
      expect(comments[0].emotions[0].author).to eql('Joe')
      expect(comments[0].emotions[1].author).to eql('Anonymous')
    end
  end

  describe 'projecting virtual attributes' do
    it 'loads auto-mapped structs' do
      user = repo.users.
               inner_join(:posts, author_id: :id).
               select_group { [id.qualified, name.qualified] }.
               select_append { int::count(:posts).as(:post_count) }.
               having { count(id.qualified) >= 1 }.
               first

      expect(user.id).to be(1)
      expect(user.name).to eql('Jane')
      expect(user.post_count).to be(1)
    end
  end

  describe 'projecting aliased attributes' do
    it 'loads auto-mapped structs' do
      user = repo.users.select { [id.aliased(:userId), name.aliased(:userName)] }.first

      expect(user.userId).to be(1)
      expect(user.userName).to eql('Jane')
    end
  end

  context 'with a table without columns' do
    before { conn.create_table(:dummy) unless conn.table_exists?(:dummy) }

    it 'does not fail with a weird error when a relation does not have attributes' do
      configuration.relation(:dummy) { schema(infer: true) }

      repo = Class.new(ROM::Repository[:dummy]).new(rom)
      expect(repo.dummy.to_a).to eql([])
    end
  end

  describe 'mapping without structs' do
    shared_context 'plain hash mapping' do
      describe '#one' do
        it 'returns a hash' do
          expect(repo.users.limit(1).one).to eql(id: 1, name: 'Jane')
        end

        it 'returns a nested hash for an aggregate' do
          expect(repo.aggregate(:posts).limit(1).one).
            to eql(id: 1, name: 'Jane', posts: [{ id: 1, author_id: 1, title: 'Hello From Jane', body: 'Jane Post'}])
        end
      end
    end

    context 'with auto_struct disabled upon initialization' do
      subject(:repo) do
        repo_class.new(rom, auto_struct: false)
      end

      include_context 'plain hash mapping'
    end

    context 'with auto_struct disabled at the class level' do
      before do
        repo_class.auto_struct(false)
      end

      include_context 'plain hash mapping'
    end
  end
end
