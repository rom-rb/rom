# frozen_string_literal: true

require 'rom/repository'

RSpec.describe ROM::Repository, '.new' do
  include_context 'database'

  subject(:repo_class) do
    Class.new(ROM::Repository[:users])
  end

  it 'includes a relation reader module on a single instance' do
    reader_modules = repo_class.new(rom).class.ancestors.select { |mod|
      mod.is_a?(ROM::Repository::RelationReader)
    }

    expect(reader_modules.length).to eq(1)
  end

  it 'does not include multiple relation reader modules with multiple instances' do
    _first_instance = repo_class.new(rom)

    reader_modules = repo_class.new(rom).class.ancestors.select { |mod|
      mod.is_a?(ROM::Repository::RelationReader)
    }

    expect(reader_modules.length).to eq(1)
  end
end
