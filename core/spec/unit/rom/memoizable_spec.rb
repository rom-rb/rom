# frozen_string_literal: true

require 'rom/support/memoizable'

RSpec.describe ROM::Memoizable, '.memoize' do
  subject(:object) do
    Class.new do
      include ROM::Memoizable

      def foo
        %w[a ab abc].max
      end
      memoize :foo

      def bar(arg)
        { a: '1', b: '2' }
      end
      memoize :bar
    end.new
  end

  it 'memoizes method return value' do
    expect(object.foo).to be(object.foo)
  end

  it 'memoizes method return value with an arg' do
    expect(object.bar(:a)).to be(object.bar(:a))
  end
end
