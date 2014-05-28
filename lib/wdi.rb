require "wdi/version"
require "wdi/config"
require "wdi/folder"

module WDI
  DEFAULT_CONFIG_FILE = File.expand_path("../../data/default-config.json", __FILE__)

  class ConfigError < Exception; end
  class FolderError < Exception; end
end
