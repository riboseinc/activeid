require "activeuuid/version"
require "activeuuid/utils"
require "activeuuid/patches"
require "activeuuid/uuid"
require "activeuuid/railtie" if defined?(Rails::Railtie)
require "pp"

module ActiveUUID
end

ActiveUUID::Patches.apply!
