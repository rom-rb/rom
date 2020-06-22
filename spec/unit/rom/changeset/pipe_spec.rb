# frozen_string_literal: true

require 'rom/changeset/pipe'

RSpec.describe ROM::Changeset::Pipe do
  context 'with default processor and options' do
    subject(:pipe) do
      Class.new(ROM::Changeset::Pipe).new
    end

    it 'sets up identity as the default processor' do
      expect(pipe.call(foo: 'bar')).to eql(foo: 'bar')
    end

    it 'sets up identity as the default diff processor' do
      expect(pipe.for_diff(foo: 'bar')).to eql(foo: 'bar')
    end
  end

  context 'with a custom processor and default options' do
    subject(:pipe) do
      Class.new(ROM::Changeset::Pipe) {
        define! do
          rename_keys user_name: :name
        end
      }.new
    end

    it 'sets up the processor' do
      expect(pipe.call(user_name: 'Jane')).to eql(name: 'Jane')
    end

    it 'sets up the same diff processor' do
      expect(pipe.for_diff(user_name: 'Jane')).to eql(name: 'Jane')
    end
  end

  context 'with a custom processor that uses an instance method and default options' do
    subject(:pipe) do
      Class.new(ROM::Changeset::Pipe) {
        define! do
          custom_method
        end

        def custom_method(value)
          value.merge(test: true)
        end
      }.new
    end

    it 'sets up the processor' do
      expect(pipe.call(name: 'Jane')).to eql(name: 'Jane', test: true)
    end

    it 'sets up the same diff processor' do
      expect(pipe.for_diff(name: 'Jane')).to eql(name: 'Jane', test: true)
    end
  end

  context 'with a custom processor injected in' do
    subject(:pipe) do
      Class.new(ROM::Changeset::Pipe).new(processor)
    end

    let(:processor) do
      :upcase.to_proc
    end

    it 'sets up the processor' do
      expect(pipe.call('Jane')).to eql('JANE')
    end

    it 'sets up the same diff processor' do
      expect(pipe.for_diff('Jane')).to eql('JANE')
    end
  end

  context 'with a custom diff processor injected in' do
    subject(:pipe) do
      Class.new(ROM::Changeset::Pipe).new(diff_processor: diff_processor)
    end

    let(:diff_processor) do
      :upcase.to_proc
    end

    it 'sets up the default processor' do
      expect(pipe.call('Jane')).to eql('Jane')
    end

    it 'sets up custom diff processor' do
      expect(pipe.for_diff('Jane')).to eql('JANE')
    end
  end
end
