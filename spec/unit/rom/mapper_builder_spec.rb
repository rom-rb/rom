require 'spec_helper'

describe ROM::MapperBuilder do
  subject(:builder) { ROM::MapperBuilder.new(:users, relation, options) }

  let(:options) { {} }
  let(:relation) { double('relation', header: []) }
  let(:header) { mapper.header }
  let(:mapper) { builder.call }

  let(:expected_header) { ROM::Header.coerce(attributes) }

  describe '#attribute' do
    context 'simple attribute' do
      let(:attributes) { [[:name]] }

      it 'adds an attribute for the header' do
        builder.attribute :name

        expect(header).to eql(expected_header)
      end
    end

    context 'aliased attribute' do
      let(:attributes) { [[:name, from: :user_name]] }

      it 'adds an aliased attribute for the header' do
        builder.attribute :name, from: :user_name

        expect(header).to eql(expected_header)
      end
    end

    context 'prefixed attribute' do
      let(:attributes) { [[:name, from: :user_name]] }
      let(:options) { { prefix: :user } }

      it 'adds an aliased attribute for the header using configured :prefix' do
        builder.attribute :name

        expect(header).to eql(expected_header)
      end
    end

    context 'symbolized attribute' do
      let(:attributes) { [[:name, from: 'name']] }
      let(:options) { { symbolize_keys: true } }

      it 'adds an attribute with symbolized alias' do
        builder.attribute :name

        expect(header).to eql(expected_header)
      end
    end
  end

  describe 'overriding inherited attributes from the relation header' do
    context 'when name matches' do
      let(:attributes) { [[:name, type: :string]] }

      it 'excludes the inherited attribute' do
        allow(relation).to receive(:header).and_return([:name])

        builder.attribute :name, type: :string

        expect(header).to eql(expected_header)
      end
    end

    context 'when alias matches' do
      let(:attributes) { [[:name, from: 'name', type: :string]] }

      it 'excludes the inherited attribute' do
        allow(relation).to receive(:header).and_return(['name'])

        builder.attribute :name, from: 'name', type: :string

        expect(header).to eql(expected_header)
      end
    end

    context 'when name in a wrapped attribute matches' do
      let(:attributes) do
        [
          [:city, type: :hash, wrap: true, header: [[:name, from: :city_name]]]
        ]
      end

      it 'excludes the inherited attribute' do
        allow(relation).to receive(:header).and_return([:city_name])

        builder.wrap :city do
          attribute :name, from: :city_name
        end

        expect(header).to eql(expected_header)
      end
    end

    context 'when name in a grouped attribute matches' do
      let(:attributes) do
        [
          [:tags, type: :array, group: true, header: [[:name, from: :tag_name]]]
        ]
      end

      it 'excludes the inherited attribute' do
        allow(relation).to receive(:header).and_return([:tag_name])

        builder.group :tags do
          attribute :name, from: :tag_name
        end

        expect(header).to eql(expected_header)
      end
    end

    context 'when name in a hash attribute matches' do
      let(:attributes) do
        [
          [:city, type: :hash, header: [[:name, from: :city_name]]]
        ]
      end

      it 'excludes the inherited attribute' do
        allow(relation).to receive(:header).and_return([:city])

        builder.embedded :city, type: :hash do
          attribute :name, from: :city_name
        end

        expect(header).to eql(expected_header)
      end
    end

    context 'when name of an array attribute matches' do
      let(:attributes) do
        [
          [:tags, type: :array, header: [[:name, from: :tag_name]]]
        ]
      end

      it 'excludes the inherited attribute' do
        allow(relation).to receive(:header).and_return([:tags])

        builder.embedded :tags, type: :array do
          attribute :name, from: :tag_name
        end

        expect(header).to eql(expected_header)
      end
    end
  end

  describe '#exclude' do
    let(:attributes) { [[:name, from: 'name']] }

    it 'removes an attribute from the inherited header' do
      allow(relation).to receive(:header).and_return(['name'])
      builder.attribute :name, from: 'name'
      expect(header).to eql(expected_header)
    end
  end

  describe '#embedded' do
    context 'when :type is set to :hash' do
      let(:attributes) { [[:city, type: :hash, header: [[:name]]]] }

      it 'adds an embedded hash attribute' do
        builder.embedded :city, type: :hash do
          attribute :name
        end

        expect(header).to eql(expected_header)
      end
    end

    context 'when :type is set to :array' do
      let(:attributes) { [[:tags, type: :array, header: [[:name]]]] }

      it 'adds an embedded array attribute' do
        builder.embedded :tags, type: :array do
          attribute :name
        end

        expect(header).to eql(expected_header)
      end
    end
  end

  describe '#wrap' do
    let(:attributes) { [[:city, type: :hash,  wrap: true, header: [[:name]]]] }

    it 'adds an wrapped hash attribute using a block to define attributes' do
      builder.wrap :city do
        attribute :name
      end

      expect(header).to eql(expected_header)
    end

    it 'adds an wrapped hash attribute using a options define attributes' do
      builder.wrap city: [:name]

      expect(header).to eql(expected_header)
    end
  end

  describe '#group' do
    let(:attributes) { [[:tags, type: :array, group: true, header: [[:name]]]] }

    it 'adds a group attribute using a block to define attributes' do
      builder.group :tags do
        attribute :name
      end

      expect(header).to eql(expected_header)
    end

    it 'adds a group attribute using a options define attributes' do
      builder.group tags: [:name]

      expect(header).to eql(expected_header)
    end
  end

  describe 'top-level :prefix option' do
    let(:options) do
      { prefix: :user }
    end

    context 'when no attribute overrides top-level setting' do
      let(:attributes) do
        [
          [:name, from: :user_name],
          [:address, from: :user_address, type: :hash, header: [
            [:city, from: :user_city]]
          ],
          [:contact, type: :hash, wrap: true, header: [
            [:mobile, from: :user_mobile]]
          ],
          [:tasks, type: :array, group: true, header: [
            [:title, from: :user_title]]
          ]
        ]
      end

      it 'sets aliased attributes using prefix automatically' do
        builder.attribute :name

        builder.embedded :address, type: :hash do
          attribute :city
        end

        builder.wrap :contact do
          attribute :mobile
        end

        builder.group :tasks do
          attribute :title
        end

        expect(header).to eql(expected_header)
      end
    end

    context 'when an attribute overrides top-level setting' do
      let(:attributes) do
        [
          [:name, from: :user_name],
          [:birthday, from: :user_birthday, type: :hash, header: [
            [:year, from: :bd_year],
            [:month, from: :bd_month],
            [:day, from: :bd_day]]
          ],
          [:address, from: :user_address, type: :hash, header: [[:city]]],
          [:contact, type: :hash, wrap: true, header: [
            [:mobile, from: :contact_mobile]]
          ],
          [:tasks, type: :array, group: true, header: [
            [:title, from: :task_title]]
          ]
        ]
      end

      it 'excludes from aliasing the ones which override it' do
        builder.attribute :name

        builder.embedded :birthday, type: :hash, prefix: :bd do
          attribute :year
          attribute :month
          attribute :day
        end

        builder.embedded :address, type: :hash, prefix: false do
          attribute :city
        end

        builder.wrap :contact, prefix: :contact do
          attribute :mobile
        end

        builder.group :tasks, prefix: :task do
          attribute :title
        end

        expect(header).to eql(expected_header)
      end
    end
  end
end
