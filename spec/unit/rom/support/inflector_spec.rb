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
    before do
      if api.instance_variables.include?(:@inflector)
        api.remove_instance_variable(:@inflector)
      end
    end

    it 'prefers ActiveSupport::Inflector' do
      expect(api.inflector == ::ActiveSupport::Inflector).to be true
    end
  end

  context 'with automatic detection' do
    before do
      if api.instance_variables.include?(:@inflector)
        api.remove_instance_variable(:@inflector)
      end
    end

    it 'automatically selects an inflector backend' do
      expect(api.inflector).not_to be nil
    end
  end

  context 'with ActiveSupport::Inflector' do
    before do
      api.select_backend(:activesupport)
    end

    it 'is ActiveSupport::Inflector' do
      expect(api.inflector).to be(::ActiveSupport::Inflector)
    end

    it_behaves_like 'an inflector'
  end

  context 'with Inflecto' do
    before do
      api.select_backend(:inflecto)
    end

    it 'is Inflecto' do
      expect(api.inflector).to be(::Inflecto)
    end

    it_behaves_like 'an inflector'
  end

  context 'an unrecognized inflector library is selected' do
    it 'raises a NameError' do
      expect { api.select_backend(:foo) }.to raise_error(NameError)
    end
  end

  context 'an inflector library cannot be found' do
    before do
      if api.instance_variables.include?(:@inflector)
        api.remove_instance_variable(:@inflector)
      end
      stub_const("ROM::Inflector::BACKENDS", {})
    end
    it 'raises a LoadError' do
      expect { api.inflector }.to raise_error(LoadError)
    end
  end
end
