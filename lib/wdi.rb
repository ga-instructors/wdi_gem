require "wdi/version"
require "wdi/config"
require "wdi/directory"

module WDI
  DEFAULT_CONFIG_FILE = File.expand_path("../../data/default-config.json", __FILE__)
  DIRECTORY_PATH      = File.expand_path(".wdi", "~")

  # autoload?

  class ConfigError < Exception; end
  class DirectoryError < Exception; end
end
