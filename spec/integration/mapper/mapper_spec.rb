# frozen_string_literal: true

RSpec.describe ROM::Mapper do
  let(:mapper_klass) do
    Class.new(ROM::Mapper).tap do |mapper_klass|
      mapper_klass.class_eval(&mapper_body)
    end
  end
  let(:mapper) { mapper_klass.build }

  subject { mapper.call(tuples) }

  describe '.attribute' do
    context 'with block' do
      let(:tuples) { [{ key: 'bar' }] }
      let(:results) { [{ key: 'foo_bar' }] }
      let(:mapper_body) do
        proc do
          attribute(:key) { |key| [prefix, key].join('_') }

          def prefix
            'foo'
          end
        end
      end

      it 'creates the attribute from the proc with the mapper as the binding' do
        is_expected.to match_array(results)
      end
    end

    context 'when copying aliased keys to multiple attributes' do
      let(:tuples) { [{ key: 'bar' }] }
      let(:results) { [{ key: 'bar', key2: 'bar', key3: 'bar' }] }
      let(:mapper_body) do
        proc do
          copy_keys true
          attribute(%i[key2 key3], from: :key)
        end
      end

      it 'creates attributes by copying keys rather than renaming' do
        is_expected.to match_array(results)
      end
    end
  end

  describe '.embedded' do
    context 'with block' do
      let(:tuples) { [{ items: { key: 'bar' } }] }
      let(:results) { [{ items: { key: 'foo_bar' } }] }
      let(:mapper_body) do
        proc do
          embedded :items, type: :hash do
            attribute(:key) { |key| [prefix, key].join('_') }
          end

          def prefix
            'foo'
          end
        end
      end

      it 'creates the attribute from the proc with the mapper as the binding' do
        is_expected.to match_array(results)
      end
    end
  end

  describe '.wrap' do
    context 'attribute with block' do
      let(:tuples) { [{ key: 'bar' }] }
      let(:results) { [{ items: { key: 'foo_bar' } }] }
      let(:mapper_body) do
        proc do
          wrap :items do
            attribute(:key) { |key| [prefix, key].join('_') }
          end

          def prefix
            'foo'
          end
        end
      end

      it 'creates the attribute from the proc with the mapper as the binding' do
        is_expected.to match_array(results)
      end
    end
  end

  describe '.unwrap' do
    context 'attribute with block' do
      let(:tuples) { [{ items: { key: 'bar' } }] }
      let(:results) { [{ key: 'foo_bar' }] }
      let(:mapper_body) do
        proc do
          unwrap :items do
            attribute(:key) { |key| [prefix, key].join('_') }
          end

          def prefix
            'foo'
          end
        end
      end

      it 'creates the attribute from the proc with the mapper as the binding' do
        is_expected.to match_array(results)
      end
    end
  end
end
