# frozen_string_literal: true

# This file loads a bunch of patches that maintain compatibility with rom 5.x.
# It is not loaded by default in 6.0. During 6.x release series, these patches
# will be gradually deprecated and eventually removed in rom 7.0.

require "rom/core"

# old api patches
require_relative "compat/global"
require_relative "compat/auto_registration"
require_relative "compat/setting_proxy"
require_relative "compat/setup"
require_relative "compat/relation"
require_relative "compat/command"
require_relative "compat/transformer"
require_relative "compat/mapper"

# new api patches
require_relative "compat/components/dsl/schema"
require_relative "compat/components"
require_relative "compat/registries"
