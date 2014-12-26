require 'spec_helper'

describe ROM::Header::Attribute::Wrap do
  describe '#to_transproc' do
    context 'with non-aliased attribute' do
      subject(:attribute) {
        ROM::Header::Attribute::Wrap.coerce([
          :task, header: [[:title]]
        ])
      }

      it 'renames wrapped attributes' do
        expect(attribute.to_transproc).to be(nil)
        transformer = attribute.preprocessor

        input = [
          { 'name' => 'Jade', :title => 'Task One' },
          { 'name' => 'Jane', :title => 'Task Two' }
        ]

        output = [
          { 'name' => 'Jade', task: { title: 'Task One' } },
          { 'name' => 'Jane', task: { title: 'Task Two' } }
        ]

        expect(transformer[input]).to eql(output)
      end
    end

    context 'with aliased attribute' do
      subject(:attribute) {
        ROM::Header::Attribute::Wrap.coerce([
          :task, header: [[:title, from: 'title']]
        ])
      }

      it 'renames wrapped attributes' do
        transformer = attribute.preprocessor + Transproc(:map_array, attribute.to_transproc)

        input = [
          { 'name' => 'Jade', 'title' => 'Task One' },
          { 'name' => 'Jane', 'title' => 'Task Two' }
        ]

        output = [
          { 'name' => 'Jade', task: { title: 'Task One' } },
          { 'name' => 'Jane', task: { title: 'Task Two' } }
        ]

        expect(transformer[input]).to eql(output)
      end
    end
  end
end
