require 'spec_helper'

describe ROM::Inflector do
  shared_examples 'an inflector' do
    it 'singularises' do
      expect(api.singularize('tasks')).to eq 'task'
    end

    it 'pluralizes' do
      expect(api.pluralize('task')).to eq 'tasks'
    end

    it 'camelizes' do
      expect(api.camelize('task_user')).to eq 'TaskUser'
    end

    it 'underscores' do
      expect(api.underscore('TaskUser')).to eq 'task_user'
    end

    it 'demodulizes' do
      expect(api.demodulize('Task::User')).to eq 'User'
    end

    it 'constantizes' do
      expect(api.constantize('String')).to equal String
    end

    it 'classifies' do
      expect(api.classify('task_user/name')).to eq 'TaskUser::Name'
    end
  end

  subject(:api) { ROM::Inflector }

  context 'with detected inflector' do
    it_behaves_like 'an inflector'
  end

  context 'with ActiveSupport::Inflector' do
    before do
      require 'active_support/inflector'
      api.instance_variable_set(:@inflector, ::ActiveSupport::Inflector)
    end
    it_behaves_like 'an inflector'
  end

  context 'with Inflecto' do
    before do
      require 'inflecto'
      api.instance_variable_set(:@inflector, ::Inflecto)
    end
    it_behaves_like 'an inflector'
  end
end
