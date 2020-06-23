# frozen_string_literal: true

RSpec.shared_context "changeset / seeds" do
  before do
    jane_id = conn[:users].insert name: "Jane"
    joe_id = conn[:users].insert name: "Joe"

    conn[:tasks].insert user_id: joe_id, title: "Joe Task"
    task_id = conn[:tasks].insert user_id: jane_id, title: "Jane Task"

    conn[:tags].insert task_id: task_id, name: "red"

    jane_post_id = conn[:posts].insert author_id: jane_id, title: "Hello From Jane", body: "Jane Post"
    joe_post_id = conn[:posts].insert author_id: joe_id, title: "Hello From Joe", body: "Joe Post"

    red_id = conn[:labels].insert name: "red"
    green_id = conn[:labels].insert name: "green"
    blue_id = conn[:labels].insert name: "blue"

    conn[:posts_labels].insert post_id: jane_post_id, label_id: red_id
    conn[:posts_labels].insert post_id: jane_post_id, label_id: blue_id

    conn[:posts_labels].insert post_id: joe_post_id, label_id: green_id

    conn[:messages].insert author: "Jane", body: "Hello folks"
    conn[:messages].insert author: "Joe", body: "Hello Jane"

    conn[:reactions].insert message_id: 1, author: "Joe"
    conn[:reactions].insert message_id: 1, author: "Anonymous"
    conn[:reactions].insert message_id: 2, author: "Jane"
  end
end
