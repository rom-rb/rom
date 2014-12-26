require 'spec_helper'

describe ROM::Header::Attribute::Array do
  describe '#to_transproc' do
    it 'builds a hash transformer' do
      attribute = ROM::Header::Attribute::Array.coerce([
        :tasks, header: [[:title, from: 'title']]
      ])

      transformer = Transproc(:map_array, attribute.to_transproc)

      input = [{
        :tasks => [
          { 'title' => 'Task One' },
          { 'title' => 'Task Two' }
        ]
      }]

      output = [ { tasks: [{ title: 'Task One' }, { title: 'Task Two' }] } ]

      expect(transformer[input]).to eql(output)
    end
  end
end
