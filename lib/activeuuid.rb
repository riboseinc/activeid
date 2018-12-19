require "activeuuid/version"
require "activeuuid/utils"
require "activeuuid/attribute_type"
require "activeuuid/patches"
require "activeuuid/uuid"
require "activeuuid/railtie" if defined?(Rails::Railtie)
require "pp"

module ActiveUUID
  class << self
    delegate :quote_as_binary, to: Utils
  end
end

ActiveUUID::Patches.apply!
