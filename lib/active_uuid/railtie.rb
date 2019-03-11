require "active_uuid"
require "rails"

module ActiveUUID
  class Railtie < Rails::Railtie
    railtie_name :activeuuid

    config.to_prepare do
      require "active_uuid/connection_patches"
    end
  end
end
