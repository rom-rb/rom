# frozen_string_literal: true

require 'rom/memory/gateway'
require 'rom/memory/relation'
require 'rom/memory/mapper_compiler'

ROM.register_adapter(:memory, ROM::Memory)
