guard :rspec, cmd: "rspec" do
  # run all specs if configuration is modified
  watch('Guardfile')           { 'spec' }
  watch('Gemfile.lock')        { 'spec' }
  watch('spec/spec_helper.rb') { 'spec' }

  # run all specs if supporting files files are modified
  watch(%r{\Aspec/(?:lib|support|shared)/.+\.rb\z}) { 'spec' }

  watch(%r{\Alib/(.+)\.rb\z}) { |_m| 'spec' }

  # run a spec if it is modified
  watch(%r{\Aspec/(?:unit|integration)/.+_spec\.rb\z})

  notification :tmux, display_message: true
end
