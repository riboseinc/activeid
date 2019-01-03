require "active_uuid/version"
require "active_uuid/utils"
require "active_uuid/model"
require "active_uuid/type"
require "active_uuid/railtie" if defined?(Rails::Railtie)
require "pp"

module ActiveUUID
  class << self
    delegate :quote_as_binary, to: Utils
  end
end
