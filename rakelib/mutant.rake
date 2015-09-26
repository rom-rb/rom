desc "Run mutant against a specific subject"
task :mutant do
  subject = ARGV.last
  if subject == 'mutant'
    abort "usage: rake mutant SUBJECT\nexample: rake mutant ROM::Header"
  else
    sep = subject.include?('#') ? '#' : '.'
    ns = subject.split(sep).first

    opts = {
      'include' => 'lib',
      'require' => 'rom',
      'use' => 'rspec',
      'ignore-subject' => "#{ns}#respond_to_missing?"
    }.to_a.map { |k, v| "--#{k} #{v}" }.join(' ')

    exec("bundle exec mutant #{opts} #{subject}")
  end
end
