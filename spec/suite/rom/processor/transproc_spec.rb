# frozen_string_literal: true

require "rom/processor/transformer"

RSpec.describe ROM::Processor::Transformer do
  subject(:transformer) { ROM::Processor::Transformer.build(binding, header) }

  let(:binding) { nil }
  let(:header) { ROM::Header.coerce(attributes, options) }
  let(:options) { {} }

  context "no mapping" do
    let(:attributes) { [[:name]] }
    let(:relation) { [{name: "Jane"}, {name: "Joe"}] }

    it "returns tuples" do
      expect(transformer[relation]).to eql(relation)
    end
  end

  context "coercing values" do
    let(:attributes) { [[:name, type: :string], [:age, type: :integer]] }
    let(:relation) { [{name: :Jane, age: "1"}, {name: :Joe, age: "2"}] }

    it "returns tuples" do
      expect(transformer[relation]).to eql([
        {name: "Jane", age: 1}, {name: "Joe", age: 2}
      ])
    end
  end

  context "mapping to object" do
    let(:options) { {model: model} }

    let(:model) do
      Class.new(Dry::Struct) do
        attribute :name, ROM::Types::String
      end
    end

    let(:attributes) { [[:name]] }
    let(:relation) { [{name: "Jane"}, {name: "Joe"}] }

    it "returns tuples" do
      expect(transformer[relation]).to eql([
        model.new(name: "Jane"), model.new(name: "Joe")
      ])
    end
  end

  context "renaming keys" do
    let(:attributes) do
      [[:name, from: "name"]]
    end

    let(:options) do
      {reject_keys: true}
    end

    let(:relation) do
      [
        {"name" => "Jane", "age" => 21}, {"name" => "Joe", age: 22}
      ]
    end

    it "returns tuples with rejected keys" do
      expect(transformer[relation]).to eql([{name: "Jane"}, {name: "Joe"}])
    end
  end

  context "copying keys" do
    let(:options) do
      {copy_keys: true}
    end

    let(:attributes) do
      [["b", from: "a"], ["c", from: "b"]]
    end

    let(:relation) do
      [{"a" => "copy"}]
    end

    it "copies without removing the original" do
      expect(transformer[relation]).to eql([{"a" => "copy", "b" => "copy", "c" => "copy"}])
    end
  end

  context "key from existing keys" do
    let(:attributes) do
      coercer = ->(a, b) { b + a }
      [[:c, {from: %i[a b], coercer: coercer}]]
    end

    let(:relation) do
      [
        {a: "works", b: "this"}
      ]
    end

    let(:expected_result) do
      [
        {c: "thisworks"}
      ]
    end

    let(:copy_keys_expected_result) do
      [
        {a: "works", b: "this", c: "thisworks"}
      ]
    end

    it "returns tuples a new key added based on exsiting keys" do
      expect(transformer[relation]).to eql(expected_result)
    end

    it "raises a configuration exception if coercer block does not exist" do
      attributes[0][1][:coercer] = nil
      expect { transformer[relation] }.to raise_error(ROM::MapperMisconfiguredError)
    end

    it "honors the copy_keys option" do
      options.merge!(copy_keys: true)
      expect(transformer[relation]).to eql(copy_keys_expected_result)
    end
  end

  describe "rejecting keys" do
    let(:options) { {reject_keys: true} }

    let(:attributes) do
      [
        ["name"],
        ["tasks", type: :array, group: true, header: [["title"]]]
      ]
    end

    let(:relation) do
      [
        {"name" => "Jane", "age" => 21, "title" => "Task One"},
        {"name" => "Jane", "age" => 21, "title" => "Task Two"},
        {"name" => "Joe", "age" => 22, "title" => "Task One"}
      ]
    end

    it "returns tuples with unknown keys rejected" do
      expect(transformer[relation]).to eql([
        {"name" => "Jane",
         "tasks" => [{"title" => "Task One"}, {"title" => "Task Two"}]},
        {"name" => "Joe",
         "tasks" => [{"title" => "Task One"}]}
      ])
    end
  end

  context "mapping nested hash" do
    let(:relation) do
      [
        {"name" => "Jane", "task" => {"title" => "Task One"}},
        {"name" => "Joe", "task" => {"title" => "Task Two"}}
      ]
    end

    context "when no mapping is needed" do
      let(:attributes) { [["name"], ["task", type: :hash, header: [[:title]]]] }

      it "returns tuples" do
        expect(transformer[relation]).to eql(relation)
      end
    end

    context "with deeply nested hashes" do
      context "when no renaming is required" do
        let(:relation) do
          [
            {"user" => {"name" => "Jane", "task" => {"title" => "Task One"}}},
            {"user" => {"name" => "Joe", "task" => {"title" => "Task Two"}}}
          ]
        end

        let(:attributes) do
          [[
            "user", type: :hash, header: [
              ["name"],
              ["task", type: :hash, header: [["title"]]]
            ]
          ]]
        end

        it "returns tuples" do
          expect(transformer[relation]).to eql(relation)
        end
      end

      context "when renaming is required" do
        let(:relation) do
          [
            {user: {name: "Jane", task: {title: "Task One"}}},
            {user: {name: "Joe", task: {title: "Task Two"}}}
          ]
        end

        let(:attributes) do
          [[
            "user", type: :hash, header: [
              ["name"],
              ["task", type: :hash, header: [["title"]]]
            ]
          ]]
        end

        it "returns tuples" do
          expect(transformer[relation]).to eql(relation)
        end
      end
    end

    context "renaming keys" do
      context "when only hash needs renaming" do
        let(:attributes) do
          [
            ["name"],
            [:task, from: "task", type: :hash, header: [[:title, from: "title"]]]
          ]
        end

        it "returns tuples with key renamed in the nested hash" do
          expect(transformer[relation]).to eql([
            {"name" => "Jane", :task => {title: "Task One"}},
            {"name" => "Joe", :task => {title: "Task Two"}}
          ])
        end
      end

      context "when all attributes need renaming" do
        let(:attributes) do
          [
            [:name, from: "name"],
            [:task, from: "task", type: :hash, header: [[:title, from: "title"]]]
          ]
        end

        it "returns tuples with key renamed in the nested hash" do
          expect(transformer[relation]).to eql([
            {name: "Jane", task: {title: "Task One"}},
            {name: "Joe", task: {title: "Task Two"}}
          ])
        end
      end
    end
  end

  context "wrapping tuples" do
    let(:relation) do
      [
        {"name" => "Jane", "title" => "Task One"},
        {"name" => "Joe", "title" => "Task Two"}
      ]
    end

    context "when no mapping is needed" do
      let(:attributes) do
        [
          ["name"],
          ["task", type: :hash, wrap: true, header: [["title"]]]
        ]
      end

      it "returns wrapped tuples" do
        expect(transformer[relation]).to eql([
          {"name" => "Jane", "task" => {"title" => "Task One"}},
          {"name" => "Joe", "task" => {"title" => "Task Two"}}
        ])
      end
    end

    context "with deeply wrapped tuples" do
      let(:attributes) do
        [
          ["user", type: :hash, wrap: true, header: [
            ["name"],
            ["task", type: :hash, wrap: true, header: [["title"]]]
          ]]
        ]
      end

      it "returns wrapped tuples" do
        expect(transformer[relation]).to eql([
          {"user" => {"name" => "Jane", "task" => {"title" => "Task One"}}},
          {"user" => {"name" => "Joe", "task" => {"title" => "Task Two"}}}
        ])
      end
    end

    context "renaming keys" do
      context "when only wrapped tuple requires renaming" do
        let(:attributes) do
          [
            ["name"],
            ["task", type: :hash, wrap: true, header: [[:title, from: "title"]]]
          ]
        end

        it "returns wrapped tuples with renamed keys" do
          expect(transformer[relation]).to eql([
            {"name" => "Jane", "task" => {title: "Task One"}},
            {"name" => "Joe", "task" => {title: "Task Two"}}
          ])
        end
      end

      context "when all attributes require renaming" do
        let(:attributes) do
          [
            [:name, from: "name"],
            [:task, type: :hash, wrap: true, header: [[:title, from: "title"]]]
          ]
        end

        it "returns wrapped tuples with all keys renamed" do
          expect(transformer[relation]).to eql([
            {name: "Jane", task: {title: "Task One"}},
            {name: "Joe", task: {title: "Task Two"}}
          ])
        end
      end
    end
  end

  context "unwrapping tuples" do
    let(:relation) do
      [
        {"user" => {"name" => "Leo", "task" => {"title" => "Task 1"}}},
        {"user" => {"name" => "Joe", "task" => {"title" => "Task 2"}}}
      ]
    end

    context "when no mapping is needed" do
      let(:attributes) do
        [
          ["user", type: :hash, unwrap: true, header: [["name"], ["task"]]]
        ]
      end

      it "returns unwrapped tuples" do
        expect(transformer[relation]).to eql([
          {"name" => "Leo", "task" => {"title" => "Task 1"}},
          {"name" => "Joe", "task" => {"title" => "Task 2"}}
        ])
      end
    end

    context "partially" do
      context "without renaming the rest of the wrap" do
        let(:attributes) do
          [
            ["user", type: :hash, unwrap: true, header: [["task"]]]
          ]
        end

        it "returns unwrapped tuples" do
          expect(transformer[relation]).to eql([
            {"user" => {"name" => "Leo"}, "task" => {"title" => "Task 1"}},
            {"user" => {"name" => "Joe"}, "task" => {"title" => "Task 2"}}
          ])
        end
      end

      context "with renaming the rest of the wrap" do
        let(:attributes) do
          [
            ["man", from: "user", type: :hash, unwrap: true, header: [["task"]]]
          ]
        end

        it "returns unwrapped tuples" do
          expect(transformer[relation]).to eql([
            {"man" => {"name" => "Leo"}, "task" => {"title" => "Task 1"}},
            {"man" => {"name" => "Joe"}, "task" => {"title" => "Task 2"}}
          ])
        end
      end
    end

    context "deeply" do
      let(:attributes) do
        [
          ["user", type: :hash, unwrap: true, header: [
            ["name"],
            ["title"],
            ["task", type: :hash, unwrap: true, header: [["title"]]]
          ]]
        ]
      end

      it "returns unwrapped tuples" do
        expect(transformer[relation]).to eql([
          {"name" => "Leo", "title" => "Task 1"},
          {"name" => "Joe", "title" => "Task 2"}
        ])
      end
    end
  end

  context "grouping tuples" do
    let(:relation) do
      [
        {"name" => "Jane", "title" => "Task One"},
        {"name" => "Jane", "title" => "Task Two"},
        {"name" => "Joe", "title" => "Task One"},
        {"name" => "Joe", "title" => nil}
      ]
    end

    context "when no mapping is needed" do
      let(:attributes) do
        [
          ["name"],
          ["tasks", type: :array, group: true, header: [["title"]]]
        ]
      end

      it "returns wrapped tuples with all keys renamed" do
        expect(transformer[relation]).to eql([
          {"name" => "Jane",
           "tasks" => [{"title" => "Task One"}, {"title" => "Task Two"}]},
          {"name" => "Joe",
           "tasks" => [{"title" => "Task One"}]}
        ])
      end
    end

    context "renaming keys" do
      context "when only grouped tuple requires renaming" do
        let(:attributes) do
          [
            ["name"],
            ["tasks", type: :array, group: true, header: [[:title, from: "title"]]]
          ]
        end

        it "returns grouped tuples with renamed keys" do
          expect(transformer[relation]).to eql([
            {"name" => "Jane",
             "tasks" => [{title: "Task One"}, {title: "Task Two"}]},
            {"name" => "Joe",
             "tasks" => [{title: "Task One"}]}
          ])
        end
      end

      context "when all attributes require renaming" do
        let(:attributes) do
          [
            [:name, from: "name"],
            [:tasks, type: :array, group: true, header: [[:title, from: "title"]]]
          ]
        end

        it "returns grouped tuples with all keys renamed" do
          expect(transformer[relation]).to eql([
            {name: "Jane",
             tasks: [{title: "Task One"}, {title: "Task Two"}]},
            {name: "Joe",
             tasks: [{title: "Task One"}]}
          ])
        end
      end
    end

    context "nested grouping" do
      let(:relation) do
        [
          {name: "Jane", title: "Task One", tag: "red"},
          {name: "Jane", title: "Task One", tag: "green"},
          {name: "Joe", title: "Task One", tag: "blue"}
        ]
      end

      let(:attributes) do
        [
          [:name],
          [:tasks, type: :array, group: true, header: [
            [:title],
            [:tags, type: :array, group: true, header: [[:tag]]]
          ]]
        ]
      end

      it "returns deeply grouped tuples" do
        expect(transformer[relation]).to eql([
          {name: "Jane",
           tasks: [
             {title: "Task One", tags: [{tag: "red"}, {tag: "green"}]}
           ]},
          {name: "Joe",
           tasks: [
             {title: "Task One", tags: [{tag: "blue"}]}
           ]}
        ])
      end
    end
  end
end
