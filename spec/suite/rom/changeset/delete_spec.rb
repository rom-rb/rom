# frozen_string_literal: true

RSpec.describe ROM::Changeset::Delete do
  include_context "changeset / database"
  include_context "changeset / relations"

  describe ROM::Changeset::Delete do
    let(:changeset) do
      users.by_pk(user[:id]).changeset(:delete)
    end

    let(:relation) do
      users.by_pk(user[:id])
    end

    let(:user) do
      users.command(:create).call(name: "Jane")
    end

    it "has relation" do
      expect(changeset.relation).to eql(relation)
    end

    it "can be commited" do
      expect(changeset.commit.to_h).to eql(id: 1, name: "Jane")
      expect(relation.one).to be(nil)
    end
  end

  describe "custom changeset class" do
    context "with a Create" do
      let(:changeset) do
        users.changeset(changeset_class[:users], {})
      end

      let(:changeset_class) do
        Class.new(ROM::Changeset::Create) do
          def to_h
            __data__.merge(name: "Jane")
          end
        end
      end

      it "has data" do
        expect(changeset.to_h).to eql(name: "Jane")
      end

      it "has relation" do
        expect(changeset.relation).to be(users)
      end

      it "can be commited" do
        expect(changeset.commit.to_h).to eql(id: 1, name: "Jane")
      end
    end

    context "with an Update" do
      let(:changeset) do
        users.by_pk(user.id).changeset(changeset_class, name: "Jade")
      end

      let(:changeset_class) do
        Class.new(ROM::Changeset::Update[:users]) do
          map { |t| t.merge(name: "#{t[:name]} Doe") }
        end
      end

      let(:user) do
        users.command(:create).call(name: "Jane")
      end

      it "has data" do
        expect(changeset.to_h).to eql(name: "Jade Doe")
      end

      it "has relation restricted by pk" do
        expect(changeset.relation).to eql(users.by_pk(user.id))
      end

      it "can be commited" do
        expect(changeset.commit.to_h).to eql(id: 1, name: "Jade Doe")
      end
    end
  end

  it "raises ArgumentError when unknown type was used" do
    expect {
      users.changeset(:not_here)
    }.to raise_error(
      ArgumentError,
      "+:not_here+ is not a valid changeset type. Must be one of: [:create, :update, :delete]"
    )
  end

  it "raises ArgumentError when unknown class was used" do
    klass = Class.new {
      def self.name
        "SomeClass"
      end
    }

    expect { users.changeset(klass) }
      .to raise_error(ArgumentError, /SomeClass/)
  end
end
