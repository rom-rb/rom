SimpleCov.command_name "spec:#{SPEC_ROOT.join('..').basename}"

SimpleCov.root(SPEC_ROOT.join('../..').to_s)

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/rom-sql/'
  add_filter '/lint/'
end