require 'anima'
require 'rom-sql'

ROM.setup(:sql, 'sqlite::memory')

ROM::SQL.gateway.connection.create_table :users do
  primary_key :id
  column :name, String
end

class Users < ROM::Relation[:sql]
end

class ROM::Repository::Base # :trollface:
  attr_reader :relation, :models, :mappers

  def initialize(relation)
    @relation = relation
    @mappers = {}
    @models = {}
  end

  def load
    result = yield
    mapper_for(result).call(result)
  end

  def mapper_for(relation)
    mappers[relation] ||=
      begin
        builder = ROM::ClassBuilder.new(name: "Mapper[#{component_name}]", parent: ROM::Mapper)

        mapper = builder.call do |klass|
          klass.model model_for(relation)

          relation.columns.each do |col|
            klass.attribute col
          end
        end

        mapper.build
      end
  end

  def model_for(relation)
    header = relation.columns

    models[header] ||= ROM::ClassBuilder.new(name: "ROM::Struct[#{component_name}]", parent: Object).call do |klass|
      klass.send(:include, Anima.new(*header))
    end
  end

  def component_name
    Inflecto.classify(Inflecto.singularize(relation.name))
  end
end

class UserRepository < ROM::Repository::Base
  def all
    load { relation.select(:id, :name).order(:name, :id) }
  end
end

RSpec.describe 'ROM repository' do
  subject(:user_repo) { UserRepository.new(users) }

  let!(:model) { user_repo.model_for(users) }

  let(:rom) { ROM.finalize.env }

  let(:users) { rom.relations[:users] }

  let(:jane) { model.new(id: 1, name: 'Jane') }
  let(:joe) { model.new(id: 2, name: 'Joe') }

  before do
    ROM::SQL.gateway.connection[:users].insert name: 'Jane'
    ROM::SQL.gateway.connection[:users].insert name: 'Joe'
  end

  it 'works' do
    expect(user_repo.all).to eq([jane, joe])
  end
end
