require 'spec_helper'

describe Engine, '#base_relation' do
  subject { object.base_relation(relation) }

  let(:class_under_test) do
    klass = subclass(:TestEngine)
    klass.class_eval do
      def self.inspect; name; end
    end
    klass
  end

  let(:object)   { class_under_test.new }
  let(:relation) { mock('relation') }

  specify do
    expect { subject }.to raise_error(NotImplementedError, 'TestEngine#base_relation is not implemented')
  end
end
