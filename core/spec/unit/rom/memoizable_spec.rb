require 'rom/support/memoizable'

RSpec.describe ROM::Memoizable, '.memoize' do
  subject(:object) do
    Class.new do
      include ROM::Memoizable

      def foo
        ['a', 'ab', 'abc'].max
      end
      memoize :foo
    end.new
  end

  it 'memoizes method return value' do
    expect(object.foo).to be(object.foo)
  end
end
