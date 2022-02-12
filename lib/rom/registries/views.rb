# frozen_string_literal: true

require_relative "nestable"

module ROM
  module Registries
    class Views < Root
      prepend Nestable
    end
  end
end
