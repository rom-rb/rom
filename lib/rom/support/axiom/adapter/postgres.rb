require 'do_postgres'

require 'rom/support/axiom/adapter'
require 'rom/support/axiom/adapter/data_objects'

module Axiom
  module Adapter

    # A Axiom adapter for postgres
    #
    class Postgres < DataObjects

      uri_scheme :postgres

    end # class Postgres
  end # module Adapter
end # module Axiom
