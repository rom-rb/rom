require 'rom/schema'

RSpec.describe ROM::Schema, '#[]' do
  context 'with a schema' do
    subject(:schema) do
      define_schema(:users, id: :Integer, name: :String, email: :String)
    end

    it 'returns an attribute identified by its canonical name' do
      expect(schema[:email]).to eql(define_attribute(:String, { name: :email }, source: :users))
    end

    it 'returns an aliased attribute identified by its canonical name' do
      expect(schema.rename(id: :user_id)[:id]).to eql(define_attribute(:Integer, { name: :id, alias: :user_id }, source: :users))
    end

    it 'raises KeyError when attribute is not found' do
      expect { schema[:not_here] }.to raise_error(KeyError, /not_here/)
    end
  end

  context 'with a merged schema' do
    subject(:schema) do
      left.merge(right.__send__(:new, right.map { |attr| attr.meta(source: :tasks) }))
    end

    let(:left) do
      define_schema(:users, id: :Integer, name: :String)
    end

    let(:right) do
      define_schema(:tasks, id: :Integer, title: :String)
    end

    it 'returns an attribute identified by its canonical name' do
      expect(schema[:id]).to eql(define_attribute(:Integer, { name: :id }, source: :users))
    end

    it 'returns an attribute identified by its canonical name when its unique' do
      expect(schema[:title]).to eql(define_attribute(:String, { name: :title }, source: :tasks))
    end

    it 'returns an attribute identified by its canonical name and its source' do
      expect(schema[:id, :tasks]).to eql(define_attribute(:Integer, { name: :id }, source: :tasks))
    end

    it 'raises KeyError when attribute is not found' do
      expect { schema[:not_here] }.to raise_error(KeyError, /not_here/)
      expect { schema[:not_here, :tasks] }.to raise_error(KeyError, /not_here/)
    end
  end
end
