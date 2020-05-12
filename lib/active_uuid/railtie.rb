require "active_uuid"
require "rails"

module ActiveUUID
  class Railtie < Rails::Railtie
    railtie_name :activeuuid

    config.to_prepare do
      ActiveUUID::ConnectionPatches.apply!
    end
  end
end
