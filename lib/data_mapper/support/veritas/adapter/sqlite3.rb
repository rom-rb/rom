require 'do_sqlite3'

require 'data_mapper/support/veritas/adapter'
require 'data_mapper/support/veritas/adapter/data_objects'

module Veritas
  module Adapter

    # A veritas adapter for sqlite3
    #
    class Sqlite3 < DataObjects

      uri_scheme :sqlite3

    end # class Sqlite3
  end # module Adapter
end # module Veritas
