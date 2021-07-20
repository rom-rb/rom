# frozen_string_literal: true

require "ostruct"

RSpec.describe ROM::Changeset do
  let(:jane) { {id: 2, name: "Jane"} }
  let(:relation) { double(ROM::Relation, name: :users) }

  describe ".[]" do
    it "returns a changeset preconfigured for a specific relation" do
      klass = ROM::Changeset::Create[:users]

      expect(klass.relation).to be(:users)
      expect(klass < ROM::Changeset::Create).to be(true)
    end

    it "caches results" do
      create = ROM::Changeset::Create[:users]
      update = ROM::Changeset::Update[:users]

      expect(create).to be(ROM::Changeset::Create[:users])
      expect(create < ROM::Changeset::Create).to be(true)

      expect(update).to be(ROM::Changeset::Update[:users])
      expect(update < ROM::Changeset::Update).to be(true)
    end
  end

  describe "#diff" do
    it "returns a hash with changes" do
      expect(relation).to receive(:one).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, __data__: {name: "Jane Doe"})

      expect(changeset.diff).to eql(name: "Jane Doe")
    end

    it "does not consider keys that are not present on the original tuple" do
      expect(relation).to receive(:one).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation).data(foo: "bar")

      expect(changeset.diff).to eql({})
    end
  end

  describe "#diff?" do
    it "returns true when data differs from the original tuple" do
      expect(relation).to receive(:one).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation).data(name: "Jane Doe")

      expect(changeset).to be_diff
    end

    it "returns false when data are equal to the original tuple" do
      expect(relation).to receive(:one).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation).data(name: "Jane")

      expect(changeset).to_not be_diff
    end

    it "returns false when data contains keys that are not available on the original tuple" do
      expect(relation).to receive(:one).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation).data(foo: "bar")

      expect(changeset).to_not be_diff
    end

    it "uses piped data for diff" do
      expect(relation).to receive(:one).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation).data(name: "Jane").map { |t| {name: t[:name].upcase} }

      expect(changeset).to be_diff
    end
  end

  describe "#clean?" do
    it "returns true when data are equal to the original tuple" do
      expect(relation).to receive(:one).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, __data__: {name: "Jane"})

      expect(changeset).to be_clean
    end

    it "returns false when data differs from the original tuple" do
      expect(relation).to receive(:one).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, __data__: {name: "Jane Doe"})

      expect(changeset).to_not be_clean
    end
  end

  describe "quacks like a hash" do
    subject(:changeset) { ROM::Changeset::Create.new(relation, __data__: data) }

    let(:data) { instance_double(Hash, class: Hash) }

    it "delegates to its data hash" do
      expect(data).to receive(:[]).with(:name).and_return("Jane")

      expect(changeset[:name]).to eql("Jane")
    end

    it "maintains its own type" do
      expect(data).to receive(:merge).with(foo: "bar").and_return(foo: "bar")

      new_changeset = changeset.merge(foo: "bar")

      expect(new_changeset).to be_instance_of(ROM::Changeset::Create)
      expect(new_changeset.options).to eql(changeset.options.merge(__data__: {foo: "bar"}))
      expect(new_changeset.to_h).to eql(foo: "bar")
    end

    it "raises NoMethodError when an unknown message was sent" do
      expect { changeset.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end

  describe "quacks like an array" do
    subject(:changeset) { ROM::Changeset::Create.new(relation, __data__: data) }

    let(:data) { instance_double(Array, class: Array) }

    it "delegates to its data hash" do
      expect(data).to receive(:[]).with(1).and_return("Jane")

      expect(changeset[1]).to eql("Jane")
    end

    it "maintains its own type" do
      expect(data).to receive(:+).with([1, 2]).and_return([1, 2])

      new_changeset = changeset + [1, 2]

      expect(new_changeset).to be_instance_of(ROM::Changeset::Create)
      expect(new_changeset.options).to eql(changeset.options.merge(__data__: [1, 2]))
      expect(new_changeset.to_a).to eql([1, 2])
    end

    it "raises NoMethodError when an unknown message was sent" do
      expect { changeset.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end

  describe "quacks like a custom object" do
    subject(:changeset) { ROM::Changeset::Create.new(relation, __data__: data) }

    let(:data) { OpenStruct.new(name: "Jane") }

    it "delegates to its data hash" do
      expect(changeset[:name]).to eql("Jane")
    end

    it "raises NoMethodError when an unknown message was sent" do
      expect { changeset.not_here }.to raise_error(NoMethodError, /not_here/)
    end

    it "has correct result type" do
      expect(changeset.result).to be(:one)
    end
  end

  describe "#inspect" do
    context "with a stateful changeset" do
      subject(:changeset) { ROM::Changeset::Create.new(relation).data(name: "Jane") }

      specify do
        expect(changeset.inspect)
          .to eql('#<ROM::Changeset::Create relation=:users data={:name=>"Jane"}>')
      end
    end

    context "with a data-less changeset" do
      subject(:changeset) { ROM::Changeset::Delete.new(relation) }

      specify do
        expect(changeset.inspect)
          .to eql("#<ROM::Changeset::Delete relation=:users>")
      end
    end
  end
end
