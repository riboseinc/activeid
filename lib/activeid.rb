require "activeid/version"
require "activeid/utils"
require "activeid/model"
require "activeid/type"
require "activeid/railtie" if defined?(Rails::Railtie)
require "pp"

module ActiveID
  class << self
    delegate :quote_as_binary, to: Utils
  end
end
