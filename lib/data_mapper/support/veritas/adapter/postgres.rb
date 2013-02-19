require 'do_postgres'

require 'data_mapper/support/veritas/adapter'
require 'data_mapper/support/veritas/adapter/data_objects'

module Veritas
  module Adapter

    # A veritas adapter for postgres
    #
    class Postgres < DataObjects

      uri_scheme :postgres

    end # class Postgres
  end # module Adapter
end # module Veritas
