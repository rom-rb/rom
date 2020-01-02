# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ROM::Configurable do
  let (:klass) { Class.new { include ROM::Configurable } }
  let (:object) { klass.new }
  let (:config) { object.config }

  it 'exposes the config property' do
    expect { config }.not_to raise_error
  end

  it 'is configurable via block' do
    object.configure do |config|
      config.sql.infer_relations = false
    end

    expect(config.sql.infer_relations).to be(false)
  end

  context ROM::Configurable::Config do
    it 'can be traversed via dot syntax' do
      config.sql.infer_relations = false
      expect(config.sql.infer_relations).to be(false)
    end

    it 'can be traversed via bracket syntax' do
      config[:sql].infer_relations = false

      expect(config[:sql][:infer_relations]).to be(false)
      expect(config).to respond_to(:sql)
      expect(config.sql.infer_relations).to be(false)
    end

    it 'freezes properly' do
      config.freeze

      expect { config.sql.infer_relations = false }.to raise_error(NoMethodError)
    end

    it 'handles unset keys when frozen' do
      config.sql.infer_relations = false
      config.freeze

      expect(config.other).to be(nil)
      expect(config.key?(:other)).to be(false)
      expect(config.key?(:sql)).to be(true)
    end
  end
end
