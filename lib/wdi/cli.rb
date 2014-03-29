require "wdi"
require "wdi/folder"
require "thor"

module WDI
  class CLI < Thor
    desc "init", "initialize a new WDI directory at ~/.wdi"
    method_option :load, 
                  aliases: ["-l"],
                  default: WDI::DEFAULT_CONFIG_FILE, 
                  desc:    "Load the WDI config(.json) from a local file or URI path."
    method_option :force,
                  aliases: ["-f"],
                  default: false,
                  desc:    "Force overwrite of the current WDI directory, if it exists."
    def init
      begin
        WDI::Config::load(options[:load])
        WDI::Folder::create_with_config(options[:force])
      
      rescue WDI::ConfigError, WDI::FolderError => e
        say e.message, :red
      end
    end
  end
end