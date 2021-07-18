# frozen_string_literal: true

require "pathname"

SPEC_ROOT = Pathname(__FILE__).dirname

require "warning"

Warning.ignore(/equalizer/)
Warning.ignore(/byebug/)
Warning.ignore(/zeitwerk/)
Warning.ignore(/pry-byebug/)
Warning.ignore(/sequel/)
Warning.ignore(/mysql2/)
Warning.ignore(/rspec-core/)
Warning.ignore(/__FILE__/)
Warning.ignore(/__LINE__/)
Warning.process { |w| raise w } if ENV["FAIL_ON_WARNINGS"].eql?("true")

# rubocop:disable Lint/SuppressedException
begin
  require "pry-byebug"
rescue LoadError
end
# rubocop:enable Lint/SuppressedException

require "dry/core/deprecations"
Dry::Core::Deprecations.set_logger!(SPEC_ROOT.join("../log/deprecations.log"))

require_relative "support/types"

require "rom/core"
require "rom/compat"
require "rom/memory"

Dir[SPEC_ROOT.join("shared/**/*.rb")].sort.each do |file|
  require "#{file}"
end

module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

RSpec.configure do |config|
  if ENV["PROFILE"] == "true"
    require_relative "support/spec_profiler"
    config.reporter.extend(SpecProfiler)
  end

  require_relative "support/helpers/schema_helpers"
  config.include(SchemaHelpers)

  require_relative "support/helpers/mapper_registry"
  config.include(MapperRegistry)

  config.after do
    gateway.disconnect if respond_to?(:gateway) && gateway.respond_to?(:disconnect)
    Test.remove_constants
  end

  config.define_derived_metadata file_path: %r{/suite/} do |metadata|
    metadata[:group] = metadata[:file_path]
      .split("/")
      .then { |parts| parts[parts.index("suite") + 1] }
      .to_sym
  end

  %i[rom legacy compat].each do |group|
    # rubocop:disable Lint/SuppressedException
    config.when_first_matching_example_defined group: group do
      require_relative "support/#{group}"
    rescue LoadError
    end
    # rubocop:enable Lint/SuppressedException
  end
end
