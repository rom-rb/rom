if RUBY_VERSION < '1.9'
  class OpenStruct
    def id
      @table.fetch(:id) { super }
    end
  end
end

%w(shared support).each do |name|
  Dir[File.expand_path("../#{name}/**/*.rb", __FILE__)].each do |file|
    require file
  end
end
