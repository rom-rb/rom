# frozen_string_literal: true

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

  context 'with struct namespaces' do
    subject(:mapper_compiler) { ROM::MapperCompiler.new }

    let(:relation) do
      ROM::Relation.new(
        [],
        name: ROM::Relation::Name[:users],
        schema: define_schema(:users, id: :Integer, name: :String),
        auto_struct: true
      )
    end

    # On JRuby, Hash#hash often returns the same value for hashes that differ only in a module or
    # class value, so relation ASTs that differ only by their struct namespace (held in the AST's
    # meta hash) often return the same hash. Stub the meta hash's Hash#hash to force that collision
    # here.
    it 'builds structs in each namespace when the AST meta hashes collide' do
      namespaces = [Module.new, Module.new]

      structs = namespaces.map do |ns|
        ast = relation.struct_namespace(ns).to_ast
        meta = ast[1][2]
        def meta.hash = 1

        mapper_compiler.call(ast).call(data).first
      end

      expect(structs.zip(namespaces)).to all(satisfy { |struct, ns| struct.is_a?(ns::User) })
    end

    # Exercise JRuby's real Hash#hash. Without the fix, the first wrong mapper appears after about
    # 150 namespaces.
    it 'builds structs in each of many namespaces', if: RUBY_ENGINE == 'jruby' do
      namespaces = Array.new(500) { Module.new }

      structs = namespaces.map do |ns|
        mapper_compiler.call(relation.struct_namespace(ns).to_ast).call(data).first
      end

      expect(structs.zip(namespaces)).to all(satisfy { |struct, ns| struct.is_a?(ns::User) })
    end
  end
end
