RSpec.describe ROM::Registries::Root do
  subject(:registry) do
    ROM::Registries::Root.new
  end

  describe "#[]" do
    it "returns a registered component" do
      users = double(:users)
      registry.container.register("relations.users", users)

      expect(registry["relations.users"]).to be(users)
    end

    it "raises when the requested component is not registered" do
      expect { registry.relations[:users] }.to raise_error(ROM::RelationMissingError)
    end
  end

  describe "#infer" do
    it "infers a dataset using provided gateway type" do
      dataset = registry.datasets.infer(:users, adapter: :memory)

      expect(dataset).to eql([])
    end

    it "infers a schema" do
      pending "schema's name is not being set yet"

      schema = registry.schemas.infer(:users)

      expect(schema).to be_a(ROM::Schema)
      expect(schema.name).to eql(ROM::Relation::Name[:users])
    end
  end
end
