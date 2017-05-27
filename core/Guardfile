group :red_green_refactor, halt_on_fail: true do
  guard :rspec, cmd: "rspec", all_on_start: true do
    # run all specs if Gemfile.lock is modified
    watch('Gemfile.lock') { 'spec' }

    # run all specs if any library code is modified
    watch(%r{\Alib/.+\.rb\z}) { 'spec' }

    # run all specs if supporting files are modified
    watch('spec/spec_helper.rb') { 'spec' }
    watch(%r{\Aspec/(?:lib|support|shared)/.+\.rb\z}) { 'spec' }

    # run a spec if it is modified
    watch(%r{\Aspec/(?:unit|integration)/.+_spec\.rb\z})

    notification :tmux, display_message: true if ENV.key?('TMUX')
  end

  guard :rubocop do
    # run rubocop on modified file
    watch(%r{\Alib/.+\.rb\z})
    watch(%r{\Aspec/.+\.rb\z})
  end
end
