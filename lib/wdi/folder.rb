require "wdi/config"
require "fileutils"
require "json"

module WDI
  module Folder
    def self.path
      File.expand_path(".wdi", "~")
    end

    def self.exists?
      File.exists?(self.path)
    end

    def self.create(remove_current_directory)
      self.remove! if remove_current_directory

      raise WDI::FolderError, \
        "The .wdi folder already exists. Either remove it to initialize anew, " + \
        "or use `wdi config` to edit the config file."  if self.exists?

      Dir.mkdir self.path
    end

    def self.create_with_config(remove_current_directory, file)
      self.create(remove_current_directory)
      WDI::Config::create(file)
    end

    def self.remove!
      FileUtils.rm_rf(self.path) if self.exists?
    end
  end
end