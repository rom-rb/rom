require 'rom'

require 'rom/plugins/relation/view'
require 'rom/plugins/relation/key_inference'

require 'rom/plugins/relation/sql/auto_combine'
require 'rom/plugins/relation/sql/auto_wrap'

require 'rom/repository/base'

if defined?(ROM::SQL)
  class ROM::SQL::Relation < ROM::Relation
    use :key_inference
    use :view
    use :auto_combine
    use :auto_wrap
  end
end
