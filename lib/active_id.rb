require "active_id/version"
require "active_id/utils"
require "active_id/model"
require "active_id/type"
require "active_id/railtie" if defined?(Rails::Railtie)
require "pp"

module ActiveID
  class << self
    delegate :quote_as_binary, to: Utils
  end
end
