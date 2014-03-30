require "wdi"
require "wdi/folder"
require "wdi/config"
require "thor"

module WDI
  module CLI
    class Config < Thor
      desc "set", "set a value in the WDI config file"
      def set(key, value)
        begin
          WDI::Config::set(key, value)
          say "The key '#{key}' in the WDI config file has been set to '#{value}'.", :green
        rescue WDI::ConfigError => e
          say e.message, :red
        end
      end

      desc "get", "get a value from the WDI config file"
      def get(key)
        begin
          say WDI::Config::get(WDI::Config::translate(key), key)
        rescue WDI::ConfigError => e
          say e.message, :red
        end
      end

      # desc "add", "an alias for set that appends values to a key's list (if the values are in an array)"
      # def add(key, *values)

      # end

      # desc "remove", "deletes a key from the config file"
      # method_option :force,
      #               aliases: ["-f"],
      #               default: false,
      #               desc:    "Force key's removal, if it exists, without prompting the user for confirmation."
      # def remove(key)

      # end

      desc "keys", "list the keys in the WDI config file"
      def keys(key=nil)
        begin
          say WDI::Config::keys(WDI::Config::translate(key), key).join("\n")
        rescue WDI::ConfigError => e
          say e.message, :red
        end
      end
    end

    class Wdi < Thor
      #class_option :version, alias: "-v", type: :boolean

      desc "version", "get current WDI tool version"
      def version
        say WDI::VERSION
      end

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
          WDI::Folder::create_with_config(options[:force], options[:load])
          say "The .wdi folder and config file have been created.", :green
        rescue WDI::ConfigError, WDI::FolderError => e
          say e.message, :red
        end
      end

      desc "config SUBCOMMAND ...ARGS", "interact with the WDI config file"
      subcommand "config", WDI::CLI::Config
    end
  end
end