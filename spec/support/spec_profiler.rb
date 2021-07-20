# frozen_string_literal: true

module SpecProfiler
  def report(*)
    require "hotch"

    Hotch() do
      super
    end
  end
end
