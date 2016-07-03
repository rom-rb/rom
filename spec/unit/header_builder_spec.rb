RSpec.describe 'header builder', '#call' do
  subject(:builder) { ROM::Repository::HeaderBuilder.new }

  let(:user_struct) do
    builder.struct_builder[:users, [:header, [[:attribute, :id], [:attribute, :name]]]]
  end

  let(:task_struct) do
    builder.struct_builder[:tasks, [:header, [[:attribute, :user_id], [:attribute, :title]]]]
  end

  let(:tag_struct) do
    builder.struct_builder[:tags, [:header, [[:attribute, :user_id], [:attribute, :tag]]]]
  end

  describe 'with a relation' do
    let(:ast) do
      [:relation, [
        :users,
        { dataset: :users, combine_name: :users },
        [:header, [[:attribute, :id], [:attribute, :name]]]
      ]]
    end

    it 'produces a valid header' do
      header = ROM::Header.coerce([[:id], [:name]], model: user_struct)

      expect(builder[ast]).to eql(header)
    end
  end

  describe 'with a graph' do
    let(:ast) do
      [:relation, [
        :users,
        { dataset: :users, combine_name: :users },
        [
          :header, [
            [:attribute, :id],
            [:attribute, :name],
            [:relation, [
              :tasks,
              { dataset: :tasks, keys: { id: :user_id }, combine_type: :many, combine_name: :tasks },
              [:header, [[:attribute, :user_id], [:attribute, :title]]]
            ]],
            [:relation, [
              :tags,
              { dataset: :tags, keys: { id: :user_id }, combine_type: :many, combine_name: :tags },
              [:header, [[:attribute, :user_id], [:attribute, :tag]]]
            ]]
          ]]
        ]
      ]
    end

    it 'produces a valid header' do
      attributes = [
        [:id],
        [:name],
        [:tasks, combine: true, type: :array, keys: { id: :user_id },
         header: ROM::Header.coerce([[:user_id], [:title]], model: task_struct)],
        [:tags, combine: true, type: :array, keys: { id: :user_id },
         header: ROM::Header.coerce([[:user_id], [:tag]], model: tag_struct)]
      ]

      header = ROM::Header.coerce(attributes,
        model: builder.struct_builder[:users, ast[1][2]]
      )

      expect(builder[ast]).to eql(header)
    end
  end
end
