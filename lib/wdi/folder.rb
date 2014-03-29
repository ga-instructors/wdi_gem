require "wdi/config"
require "fileutils"
require "json"

module WDI
  module Folder
    def self.exists
      File.exists?(self.path)
    end

    def self.path
      File.expand_path(".wdi", "~")
    end

    def self.create_with_config(remove_current_directory)
      self.create(remove_current_directory)

      File.open(File.expand_path("config.json", self.path), "w+") do |f|
        f.write JSON.pretty_generate(WDI::Config::file)
      end
    end

    def self.create(remove_current_directory)
      self.remove if remove_current_directory

      raise WDI::FolderError, \
        "The .wdi folder already exists. Either remove it to initialize anew, " + \
        "or use `wdi config` to edit the config file."  if self.exists
      raise WDI::ConfigError, "No config file defined." if WDI::Config::file.nil?

      Dir.mkdir self.path
    end

    def self.remove
      FileUtils.rm_rf(self.path) if self.exists
    end
  end
end