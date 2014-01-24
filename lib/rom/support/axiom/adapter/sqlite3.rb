# encoding: utf-8

require 'do_sqlite3'

require 'rom/support/axiom/adapter'
require 'rom/support/axiom/adapter/data_objects'

module Axiom
  module Adapter

    # A axiom adapter for sqlite3
    #
    class Sqlite3 < DataObjects

      uri_scheme :sqlite3

    end # Sqlite3

  end # Adapter
end # Axiom
