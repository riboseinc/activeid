require "activeid"
require "rails"

module ActiveID
  class Railtie < Rails::Railtie
    railtie_name :activeid

    config.to_prepare do
      ActiveID::ConnectionPatches.apply!
    end
  end
end
