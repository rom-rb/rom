# frozen_string_literal: true

require "spec_helper"

RSpec.describe ROM::Mapper do
  subject(:mapper) do
    klass = Class.new(parent)
    options.each do |k, v|
      klass.send(k, v)
    end
    klass
  end

  let(:parent) { Class.new(ROM::Mapper) }

  let(:options) { {} }
  let(:header) { mapper.header }

  let(:expected_header) { ROM::Header.coerce(attributes) }

  describe "#attribute" do
    context "simple attribute" do
      let(:attributes) { [[:name]] }

      it "adds an attribute for the header" do
        mapper.attribute :name

        expect(header).to eql(expected_header)
      end
    end

    context "aliased attribute" do
      let(:attributes) { [[:name, {from: :user_name}]] }

      it "adds an aliased attribute for the header" do
        mapper.attribute :name, from: :user_name

        expect(header).to eql(expected_header)
      end
    end

    context "prefixed attribute" do
      let(:attributes) { [[:name, {from: :user_name}]] }
      let(:options) { {prefix: :user} }

      it "adds an aliased attribute for the header using configured :prefix" do
        mapper.attribute :name

        expect(header).to eql(expected_header)
      end
    end

    context "prefixed attribute using custom separator" do
      let(:attributes) { [[:name, {from: :'u.name'}]] }
      let(:options) { {prefix: :u, prefix_separator: "."} }

      it "adds an aliased attribute for the header using configured :prefix" do
        mapper.attribute :name

        expect(header).to eql(expected_header)
      end
    end

    context "symbolized attribute" do
      let(:attributes) { [[:name, {from: "name"}]] }
      let(:options) { {symbolize_keys: true} }

      it "adds an attribute with symbolized alias" do
        mapper.attribute :name

        expect(header).to eql(expected_header)
      end
    end
  end

  describe "copy_keys" do
    let(:attributes) { [[:name, {type: :string}]] }
    let(:options) { {copy_keys: true} }

    it "sets copy_keys for the header" do
      mapper.copy_keys true
      mapper.attribute :name, type: :string

      expect(header).to eql(expected_header)
    end
  end

  describe "reject_keys" do
    let(:attributes) { [[:name, {type: :string}]] }
    let(:options) { {reject_keys: true} }

    it "sets reject_keys for the header" do
      mapper.reject_keys true
      mapper.attribute :name, type: :string

      expect(header).to eql(expected_header)
    end
  end

  describe "overriding inherited attributes" do
    context "when name matches" do
      let(:attributes) { [[:name, {type: :string}]] }

      it "excludes the inherited attribute" do
        parent.attribute :name

        mapper.attribute :name, type: :string

        expect(header).to eql(expected_header)
      end
    end

    context "when alias matches" do
      let(:attributes) { [[:name, {from: "name", type: :string}]] }

      it "excludes the inherited attribute" do
        parent.attribute "name"

        mapper.attribute :name, from: "name", type: :string

        expect(header).to eql(expected_header)
      end
    end

    context "when name in a wrapped attribute matches" do
      let(:attributes) do
        [
          [:city, {type: :hash, wrap: true, header: [[:name, {from: :city_name}]]}]
        ]
      end

      it "excludes the inherited attribute" do
        parent.attribute :city_name

        mapper.wrap :city do
          attribute :name, from: :city_name
        end

        expect(header).to eql(expected_header)
      end
    end

    context "when name in a grouped attribute matches" do
      let(:attributes) do
        [
          [:tags, {type: :array, group: true, header: [[:name, {from: :tag_name}]]}]
        ]
      end

      it "excludes the inherited attribute" do
        parent.attribute :tag_name

        mapper.group :tags do
          attribute :name, from: :tag_name
        end

        expect(header).to eql(expected_header)
      end
    end

    context "when name in a hash attribute matches" do
      let(:attributes) do
        [
          [:city, {type: :hash, header: [[:name, {from: :city_name}]]}]
        ]
      end

      it "excludes the inherited attribute" do
        parent.attribute :city

        mapper.embedded :city, type: :hash do
          attribute :name, from: :city_name
        end

        expect(header).to eql(expected_header)
      end
    end

    context "when name of an array attribute matches" do
      let(:attributes) do
        [
          [:tags, {type: :array, header: [[:name, {from: :tag_name}]]}]
        ]
      end

      it "excludes the inherited attribute" do
        parent.attribute :tags

        mapper.embedded :tags, type: :array do
          attribute :name, from: :tag_name
        end

        expect(header).to eql(expected_header)
      end
    end
  end

  describe "#exclude" do
    let(:attributes) { [[:name, {from: "name"}]] }

    it "removes an attribute from the inherited header" do
      mapper.attribute :name, from: "name"
      expect(header).to eql(expected_header)
    end
  end

  describe "#embedded" do
    context "when :type is set to :hash" do
      let(:attributes) { [[:city, {type: :hash, header: [[:name]]}]] }

      it "adds an embedded hash attribute" do
        mapper.embedded :city, type: :hash do
          attribute :name
        end

        expect(header).to eql(expected_header)
      end
    end

    context "when :type is set to :array" do
      let(:attributes) { [[:tags, {type: :array, header: [[:name]]}]] }

      it "adds an embedded array attribute" do
        mapper.embedded :tags, type: :array do
          attribute :name
        end

        expect(header).to eql(expected_header)
      end
    end
  end

  describe "#wrap" do
    let(:attributes) { [[:city, {type: :hash, wrap: true, header: [[:name]]}]] }

    it "adds an wrapped hash attribute using a block to define attributes" do
      mapper.wrap :city do
        attribute :name
      end

      expect(header).to eql(expected_header)
    end

    it "adds an wrapped hash attribute using a options define attributes" do
      mapper.wrap city: [:name]

      expect(header).to eql(expected_header)
    end

    it "raises an exception when using a block and options to define attributes" do
      expect {
        mapper.wrap(city: [:name]) { attribute :other_name }
      }.to raise_error(ROM::MapperMisconfiguredError)
    end

    it "raises an exception when using options and a mapper to define attributes" do
      task_mapper = Class.new(ROM::Mapper) { attribute :title }
      expect {
        mapper.wrap city: [:name], mapper: task_mapper
      }.to raise_error(ROM::MapperMisconfiguredError)
    end
  end

  describe "#group" do
    let(:attributes) { [[:tags, {type: :array, group: true, header: [[:name]]}]] }

    it "adds a group attribute using a block to define attributes" do
      mapper.group :tags do
        attribute :name
      end

      expect(header).to eql(expected_header)
    end

    it "adds a group attribute using a options define attributes" do
      mapper.group tags: [:name]

      expect(header).to eql(expected_header)
    end

    it "raises an exception when using a block and options to define attributes" do
      expect {
        mapper.group(cities: [:name]) { attribute :other_name }
      }.to raise_error(ROM::MapperMisconfiguredError)
    end

    it "raises an exception when using options and a mapper to define attributes" do
      task_mapper = Class.new(ROM::Mapper) { attribute :title }
      expect {
        mapper.group cities: [:name], mapper: task_mapper
      }.to raise_error(ROM::MapperMisconfiguredError)
    end
  end

  describe "top-level :prefix option" do
    let(:options) do
      {prefix: :user}
    end

    context "when no attribute overrides top-level setting" do
      let(:attributes) do
        [
          [:name, {from: :user_name}],
          [:address, {from: :user_address, type: :hash, header: [
            [:city, {from: :user_city}]
          ]}],
          [:contact, {type: :hash, wrap: true, header: [
            [:mobile, {from: :user_mobile}]
          ]}],
          [:tasks, {type: :array, group: true, header: [
            [:title, {from: :user_title}]
          ]}]
        ]
      end

      it "sets aliased attributes using prefix automatically" do
        mapper.attribute :name

        mapper.embedded :address, type: :hash do
          attribute :city
        end

        mapper.wrap :contact do
          attribute :mobile
        end

        mapper.group :tasks do
          attribute :title
        end

        expect(header).to eql(expected_header)
      end
    end

    context "when an attribute overrides top-level setting" do
      let(:attributes) do
        [
          [:name, {from: :user_name}],
          [:birthday, {from: :user_birthday, type: :hash, header: [
            [:year, {from: :bd_year}],
            [:month, {from: :bd_month}],
            [:day, {from: :bd_day}]
          ]}],
          [:address, {from: :user_address, type: :hash, header: [[:city]]}],
          [:contact, {type: :hash, wrap: true, header: [
            [:mobile, {from: :contact_mobile}]
          ]}],
          [:tasks, {type: :array, group: true, header: [
            [:title, {from: :task_title}]
          ]}]
        ]
      end

      it "excludes from aliasing the ones which override it" do
        mapper.attribute :name

        mapper.embedded :birthday, type: :hash, prefix: :bd do
          attribute :year
          attribute :month
          attribute :day
        end

        mapper.embedded :address, type: :hash, prefix: false do
          attribute :city
        end

        mapper.wrap :contact, prefix: :contact do
          attribute :mobile
        end

        mapper.group :tasks, prefix: :task do
          attribute :title
        end

        expect(header).to eql(expected_header)
      end
    end
  end

  context "reusing mappers" do
    describe "#group" do
      let(:task_mapper) do
        Class.new(ROM::Mapper) { attribute :title }
      end

      let(:attributes) do
        [
          [:name],
          [:tasks, {type: :array, group: true, header: task_mapper.header}]
        ]
      end

      it "uses other mapper header" do
        mapper.attribute :name
        mapper.group :tasks, mapper: task_mapper

        expect(header).to eql(expected_header)
      end
    end

    describe "#wrap" do
      let(:task_mapper) do
        Class.new(ROM::Mapper) { attribute :title }
      end

      let(:attributes) do
        [
          [:name],
          [:task, {type: :hash, wrap: true, header: task_mapper.header}]
        ]
      end

      it "uses other mapper header" do
        mapper.attribute :name
        mapper.wrap :task, mapper: task_mapper

        expect(header).to eql(expected_header)
      end
    end

    describe "#embedded" do
      let(:task_mapper) do
        Class.new(ROM::Mapper) { attribute :title }
      end

      let(:attributes) do
        [
          [:name],
          [:task, {type: :hash, header: task_mapper.header}]
        ]
      end

      it "uses other mapper header" do
        mapper.attribute :name
        mapper.embedded :task, mapper: task_mapper, type: :hash

        expect(header).to eql(expected_header)
      end
    end
  end

  describe "#combine" do
    let(:attributes) do
      [
        [:title],
        [:tasks, {combine: true, type: :array, header: [[:title]]}]
      ]
    end

    it "adds combine attributes" do
      mapper.attribute :title

      mapper.combine :tasks, on: {title: :title} do
        attribute :title
      end

      expect(header).to eql(expected_header)
    end

    it "works without a block" do
      expected_header = ROM::Header.coerce(
        [
          [:title],
          [:tasks, {combine: true, type: :array, header: []}]
        ]
      )

      mapper.attribute :title

      mapper.combine :tasks, on: {title: :title}

      expect(header).to eql(expected_header)
    end
  end

  describe "#method_missing" do
    it "responds to DSL methods" do
      expect(mapper).to respond_to(:attribute)
    end
  end
end
