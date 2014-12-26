require 'spec_helper'

describe ROM::Header::Attribute::Hash do
  describe '#to_transproc' do
    it 'builds a hash transformer' do
      attribute = ROM::Header::Attribute::Hash.coerce([
        'task', header: [[:title, from: 'title']]
      ])

      transformer = Transproc(:map_array, attribute.to_transproc)

      input = [
        { 'name' => 'Jane', 'task' => { 'title' => 'Task One' } },
        { 'name' => 'Jade', 'task' => { 'title' => 'Task Two' } }
      ]

      output = [
        { 'name' => 'Jane', 'task' => { title: 'Task One' } },
        { 'name' => 'Jade', 'task' => { title: 'Task Two' } }
      ]

      expect(transformer[input]).to eql(output)
    end
  end
end
