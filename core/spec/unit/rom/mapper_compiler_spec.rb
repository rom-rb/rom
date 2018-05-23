RSpec.describe ROM::MapperCompiler, '#call' do
  subject(:mapper_compiler) do
    Class.new(ROM::MapperCompiler) do
      mapper_options(reject_keys: true)
    end.new
  end

  let(:ast) do
    ROM::Relation.new([], schema: define_schema(:users, id: :Integer, name: :String)).to_ast
  end

  let(:data) do
    [{ id: 1, name: 'Jane', email: 'jane@doe.org' }]
  end

  it 'sets mapper options' do
    mapper = mapper_compiler.call(ast)

    expect(mapper.call(data)).to eql([{ id: 1, name: 'Jane' }])
  end
end
