RSpec.describe 'ROM repository' do
  include_context 'database'
  include_context 'relations'
  include_context 'repo'
  include_context 'structs'
  include_context 'seeds'

  it 'loads a single relation' do
    expect(repo.all_users.to_a).to match_array([jane, joe])
  end

  it 'can be used with a custom mapper' do
    expect(repo.all_users_as_users.to_a).to match_array([
      Test::Models::User.new(jane),
      Test::Models::User.new(joe)
    ])
  end

  it 'loads a combine relation with one parent' do
    task = repo.tasks.combine(:user).by_pk(2).first.to_h

    expect(task).to eql(id: 2, user_id: 1, title: "Jane Task", user: { id: 1, name: "Jane" })
  end

  it 'loads belongs_to with an alias' do
    task = repo.tasks.combine(:assignee).by_pk(1).first.to_h

    expect(task).to eql(id: 1, user_id: 2, title: "Joe Task", assignee: { id: 2, name: "Joe" })
  end

  it 'loads a combined relation with many children' do
    users = repo.users.combine(:tasks).to_a.map(&:to_h)

    expect(users).to eql(
                       [
                         {:id=>1, :name=>"Jane", :tasks=>[{:id=>2, :user_id=>1, :title=>"Jane Task"}]},
                         {:id=>2, :name=>"Joe", :tasks=>[{:id=>1, :user_id=>2, :title=>"Joe Task"}]}]
                     )
  end

  it 'loads nested combined relations' do
    user = repo.users.combine(tasks: :tags).first

    expect(user.id).to be(1)
    expect(user.name).to eql('Jane')
    expect(user.tasks.size).to be(1)
    expect(user.tasks[0].id).to be(2)
    expect(user.tasks[0].title).to eql('Jane Task')
    expect(user.tasks[0].tags.size).to be(1)
    expect(user.tasks[0].tags[0].name).to eql('red')
  end

  it 'loads nested combined relations using configured associations' do
    jane = repo.users.combine(posts: :labels).first

    expect(jane.posts.size).to be(1)
    expect(jane.posts.map(&:title)).to eql(['Hello From Jane'])
    expect(jane.posts.flat_map(&:labels).flat_map(&:name)).to eql(%w(red blue))
  end

  it 'loads a wrapped relation' do
    expect(repo.tags.wrap(:task).first).to eql(tag_with_task)
  end

  it 'loads wraps using aliased relation' do
    author = repo.users.where(name: 'Jane').one

    repo.books.command(:create).(title: 'Hello World', author_id: author.id)

    book = repo.books.wrap(:author).to_a.first

    expect(book.author.id).to eql(author.id)
    expect(book.author.name).to eql(author.name)
  end

  it 'loads multiple wraps' do
    post_label = repo.posts_labels.wrap(:post).wrap(:label).to_a.first

    expect(post_label.label_id).to be(post_label.label.id)
    expect(post_label.post_id).to be(post_label.post.id)
  end

  it 'loads an aggregate via custom fks' do
    jane = repo.root.combine(:posts).where(name: 'Jane').one

    expect(jane.posts.size).to be(1)
    expect(jane.posts.first.title).to eql('Hello From Jane')
  end

  it 'loads an aggregate via assoc name' do
    jane = repo.root.combine(:posts).where(name: 'Jane').one

    expect(jane.posts.size).to be(1)
    expect(jane.posts.first.title).to eql('Hello From Jane')
  end

  it 'loads an aggregate via assoc options' do
    jane = repo.root.combine(posts: :labels).where(name: 'Jane').one

    expect(jane.name).to eql('Jane')
    expect(jane.posts.size).to be(1)
    expect(jane.posts.first.title).to eql('Hello From Jane')
    expect(jane.posts[0].labels.size).to be(2)
    expect(jane.posts[0].labels[0].name).to eql('red')
    expect(jane.posts[0].labels[1].name).to eql('blue')
  end

  it 'loads an aggregate with multiple assoc options' do
    jane = repo.root.combine(:labels, posts: :labels).where(name: 'Jane').one

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
    jane = repo.root.combine(posts: [{ author: :labels }]).where(name: 'Jane').one

    expect(jane.posts.size).to be(1)
    expect(jane.posts[0].title).to eql('Hello From Jane')

    expect(jane.posts[0].author.id).to eql(jane.id)
    expect(jane.posts[0].author.labels.size).to be(2)
    expect(jane.posts[0].author.labels[0].name).to eql('red')
    expect(jane.posts[0].author.labels[1].name).to eql('blue')
  end

  it 'loads an aggregate with multiple nodes and deeply nested assoc options' do
    jane = repo.root.combine(:books, posts: [{ author: { labels: :posts } }]).where(name: 'Jane').one

    expect(jane.books).to be_empty

    expect(jane.posts.size).to be(1)
    expect(jane.posts[0].title).to eql('Hello From Jane')

    expect(jane.posts[0].author.id).to eql(jane.id)
    expect(jane.posts[0].author.labels.size).to be(2)
    expect(jane.posts[0].author.labels[0].name).to eql('red')
    expect(jane.posts[0].author.labels[1].name).to eql('blue')

    expect(jane.posts[0].author.labels[0].posts.size).to be(1)
    expect(jane.posts[0].author.labels[0].posts[0].title).to eql('Hello From Jane')
  end

  it 'loads an aggregate with multiple associations' do
    jane = repo.root.combine(:posts, :labels).where(name: 'Jane').one

    expect(jane.posts.size).to be(1)
    expect(jane.posts.first.title).to eql('Hello From Jane')

    expect(jane.labels.size).to be(2)
    expect(jane.labels[0].name).to eql('red')
    expect(jane.labels[1].name).to eql('blue')
  end

  it 'loads children and its parents via wrap and association name' do
    label = repo.labels.combine(:posts).node(:posts) { |n| n.wrap(:author) }.first

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
    post = repo.posts.combine(:labels).where(title: 'Hello From Jane').one

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
    user = repo.users.combine(:posts, :tasks).where(name: 'Jane').one

    expect(user.name).to eql('Jane')
    expect(user.posts.size).to be(1)
    expect(user.posts[0].title).to eql('Hello From Jane')
    expect(user.tasks.size).to be(1)
    expect(user.tasks[0].title).to eql('Jane Task')
  end

  it 'loads multiple parent relations' do
    post_label = repo.posts_labels.combine(:post).first

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
    shared_context 'auto-mapping' do
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

    context 'with default namespace' do
      include_context 'auto-mapping'
    end

    context 'with custom struct namespace' do
      before do
        repo_class.struct_namespace(Test)
      end

      include_context 'auto-mapping'

      it 'uses custom namespace' do
        expect(Test.const_defined?(:User)).to be(false)
        user = repo.users.limit(1).one!

        expect(user.name).to eql('Jane')
        expect(user.class).to be < Test::User
        expect(user.class.name).to eql(Test::User.name)
      end

      it 'uses custom namespace for graph nodes' do
        expect(Test.const_defined?(:User)).to be(false)
        expect(Test.const_defined?(:Task)).to be(false)

        user = repo.users.combine(:tasks).limit(1).one!

        expect(user.name).to eql('Jane')
        expect(user.class).to be < Test::User
        expect(user.class.name).to eql(Test::User.name)

        expect(user.tasks[0].title).to eql('Jane Task')
        expect(user.tasks[0].class).to be < Test::Task
        expect(user.tasks[0].class.name).to eql(Test::Task.name)
      end
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
          expect(repo.root.combine(:posts).limit(1).one).
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

  describe 'using custom mappers along with auto-mapping' do
    before do
      configuration.mappers do
        define(:users) do
          register_as :embed_address

          def call(rel)
            rel.map { |tuple| Hash(tuple).merge(mapped: true) }
          end
        end

        define(:posts) do
          register_as :nested_mapper

          def call(rel)
            rel.map { |tuple| Hash(tuple).tap { |h| h[:title] = h[:title].upcase } }
          end
        end
      end
    end

    it 'auto-maps and applies a custom mapper' do
      jane = repo.users.combine(:posts).map_with(:embed_address, auto_struct: false).to_a.first

      expect(jane).
        to eql(id:1, name: 'Jane', mapped: true, posts: [
                 { id: 1, author_id: 1, title: 'Hello From Jane', body: 'Jane Post' }
               ])
    end

    it 'applies a custom mapper inside #node' do
      jane = repo.root.combine(:posts).node(:posts) { |posts|
        posts.map_with(:nested_mapper)
      }.first

      expect(jane).to be_a ROM::Struct

      expect(jane.to_h).
        to eql(id:1, name: 'Jane', posts: [
                 { id: 1, author_id: 1, title: 'HELLO FROM JANE', body: 'Jane Post' }
               ])
    end
  end

  describe 'using a custom model for a node' do
    before do
      class Test::Post < OpenStruct; end
    end

    it 'uses provided model for the member type' do
      jane = repo.users.
               combine(:posts).
               node(:posts) { |posts| posts.map_to(Test::Post) }.
               where(name: 'Jane').
               one

      expect(jane.name).to eql('Jane')
      expect(jane.posts.size).to be(1)
      expect(jane.posts[0]).to be_instance_of(Test::Post)
      expect(jane.posts[0].title).to eql('Hello From Jane')
      expect(jane.posts[0].body).to eql('Jane Post')
    end
  end

  it 'loads structs using plain SQL' do
    jane = repo.users.read("SELECT name FROM users WHERE name = 'Jane'").one

    expect(jane.name).to eql('Jane')
  end

  it 'uses a shared cache between relations to store struct classes' do
    post = repo.posts.mapper.model
    user_with_posts = repo.users.combine(:posts).mapper.model
    post_from_user = user_with_posts.schema.key(:posts).type.member

    expect(post).to be(post_from_user)
  end
end
